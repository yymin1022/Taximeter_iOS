//
//  MeterViewModel.swift
//  TaxiMeter
//

import Combine
import Foundation
import CoreLocation
import SwiftUI
import UIKit

public final class MeterViewModel: ObservableObject {
    @Published public var uiState: MeterUiState = MeterUiState()

    private let settingRepository: SettingRepository
    private let costRepository: CostRepository
    private let meterHistoryRepository: MeterHistoryRepository
    private let calculateMeterCostUseCase: CalculateMeterCostUseCase
    private let locationManager = CLLocationManager()

    private var meterCalculationTask: Task<Void, Never>?
    private var cityRateContinuation: AsyncStream<Bool>.Continuation?
    private var lastMeterState: MeterState?

    public init(
        settingRepository: SettingRepository = RepositoryProvider.shared.settingRepository,
        costRepository: CostRepository = RepositoryProvider.shared.costRepository,
        meterHistoryRepository: MeterHistoryRepository = RepositoryProvider.shared.meterHistoryRepository,
        calculateMeterCostUseCase: CalculateMeterCostUseCase = UseCaseProvider.shared.calculateMeterCostUseCase
    ) {
        self.settingRepository = settingRepository
        self.costRepository = costRepository
        self.meterHistoryRepository = meterHistoryRepository
        self.calculateMeterCostUseCase = calculateMeterCostUseCase

        loadAnimationFrames()
        loadAdRemovalStatus()
    }

    deinit {
        stopMeterInternal()
    }

    /// Load ad removal status
    public func loadAdRemovalStatus() {
        uiState.isAdRemoved = settingRepository.isAdRemoved()
    }

    /// Load animation frames based on current theme setting
    public func loadAnimationFrames() {
        let themeSetting = settingRepository.getCurrentTheme()
        let animationFrames: [String]
        switch themeSetting {
        case .horse:
            animationFrames = ["ic_horse_1", "ic_horse_2", "ic_horse_3"]
        case .circle:
            animationFrames = [
                "ic_circle_1", "ic_circle_2", "ic_circle_3", "ic_circle_4",
                "ic_circle_5", "ic_circle_6", "ic_circle_7", "ic_circle_8"
            ]
        }

        uiState.animationFrames = animationFrames
    }

    /// On click start meter button
    /// - Checks location permission first upon start click (identical to Android flow)
    public func onClickStart() {
        guard uiState.meterStatus == .notRunning else { return }

        let authStatus = locationManager.authorizationStatus
        switch authStatus {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            startMeterCalculation()
        case .denied, .restricted:
            showSnackBar("Location permission is required. Please enable location permission in Settings.")
        @unknown default:
            break
        }
    }

    private func startMeterCalculation() {
        let currentRegion = settingRepository.getCurrentRegion()
        let costInfo = costRepository.getCostInfo(regionKey: currentRegion.key) ?? CostInfo(region: currentRegion.key)

        let isCityRateStream = AsyncStream<Bool> { [weak self] continuation in
            guard let self = self else { return }
            self.cityRateContinuation = continuation
            continuation.yield(self.uiState.isCityRate)
        }

        // Clean initial state for new driving session
        let isAdRemoved = settingRepository.isAdRemoved()
        let frames = uiState.animationFrames
        let isCityRate = uiState.isCityRate
        uiState = MeterUiState(
            currentCost: costInfo.costBase,
            costCounter: costInfo.distBase,
            currentSpeedKph: 0.0,
            totalDistanceMeters: 0.0,
            meterStatus: .running,
            isCityRate: isCityRate,
            isNightRate: false,
            animationFrames: frames,
            isAdRemoved: isAdRemoved
        )

        // Keep screen on during driving
        UIApplication.shared.isIdleTimerDisabled = true

        #if canImport(ActivityKit)
        let initialMeterState = MeterState(
            currentCost: costInfo.costBase,
            costCounter: costInfo.distBase,
            totalDistanceMeters: 0.0,
            totalElapsedSeconds: 0.0,
            currentSpeedKph: 0.0,
            status: .running,
            isNightRate: false,
            isCityRate: isCityRate
        )
        MeterLiveActivityManager.shared.start(regionName: currentRegion.displayName, initialState: initialMeterState)
        #endif

        meterCalculationTask = Task { @MainActor in
            for await meterState in calculateMeterCostUseCase.execute(costInfo: costInfo, isCityRateStream: isCityRateStream) {
                guard !Task.isCancelled else { break }
                self.lastMeterState = meterState
                self.uiState.currentCost = meterState.currentCost
                self.uiState.costCounter = meterState.costCounter
                self.uiState.currentSpeedKph = meterState.currentSpeedKph
                self.uiState.totalDistanceMeters = meterState.totalDistanceMeters
                self.uiState.meterStatus = meterState.status
                self.uiState.isNightRate = meterState.isNightRate
                self.uiState.isCityRate = meterState.isCityRate

                #if canImport(ActivityKit)
                MeterLiveActivityManager.shared.update(state: meterState)
                #endif
            }
        }
    }

    /// Check first launch notice dialog
    public func checkFirstLaunch() {
        if settingRepository.isFirstLaunch() {
            uiState.showFirstLaunchDialog = true
        }
    }

    /// On confirm first launch notice dialog
    public func onConfirmFirstLaunch() {
        uiState.showFirstLaunchDialog = false
        settingRepository.setFirstLaunch(false)
    }

    /// On click back button
    public func onClickBack(onDismiss: () -> Void) {
        if uiState.meterStatus != .notRunning {
            uiState.showBackDialog = true
        } else {
            onDismiss()
        }
    }

    /// On cancel back dialog
    public func onCancelBack() {
        uiState.showBackDialog = false
    }

    /// On confirm back dialog
    public func onConfirmBack(onDismiss: () -> Void) {
        uiState.showBackDialog = false
        stopMeterInternal()
        onDismiss()
    }

    /// On click stop meter button
    public func onClickStop() {
        guard uiState.meterStatus != .notRunning else { return }
        uiState.showStopDialog = true
    }

    /// On cancel stop meter dialog
    public func onCancelStop() {
        uiState.showStopDialog = false
    }

    /// On confirm stop meter dialog
    public func onConfirmStop() {
        uiState.showStopDialog = false
        stopMeterInternal()
        loadAnimationFrames()
    }

    /// Toggle city rate
    public func onClickCityRate() {
        let newCityRate = !uiState.isCityRate
        uiState.isCityRate = newCityRate
        cityRateContinuation?.yield(newCityRate)
    }

    /// On click night rate button (info toast)
    public func onClickNightRate() {
        showSnackBar("Night rate will be automatically applied by time")
    }

    public func clearSnackBar() {
        uiState.snackBarMessage = nil
    }

    private func showSnackBar(_ message: String) {
        uiState.snackBarMessage = message
    }

    private func stopMeterInternal() {
        meterCalculationTask?.cancel()
        meterCalculationTask = nil
        cityRateContinuation?.finish()
        cityRateContinuation = nil

        // Save driving history if cost or distance accumulated
        if let lastState = lastMeterState, (lastState.currentCost > 0 || lastState.totalDistanceMeters > 0.0) {
            let history = MeterHistory(
                timestamp: Int64(Date().timeIntervalSince1970 * 1000),
                cost: lastState.currentCost,
                distanceMeters: lastState.totalDistanceMeters,
                elapsedSeconds: lastState.totalElapsedSeconds
            )
            let historyRepo = self.meterHistoryRepository
            Task {
                await historyRepo.insertHistory(history)
            }
        }
        lastMeterState = nil

        // Restore normal screen sleep timer
        UIApplication.shared.isIdleTimerDisabled = false

        #if canImport(ActivityKit)
        MeterLiveActivityManager.shared.stop()
        #endif

        let currentRegion = settingRepository.getCurrentRegion()
        let costInfo = costRepository.getCostInfo(regionKey: currentRegion.key) ?? CostInfo(region: currentRegion.key)
        let frames = uiState.animationFrames
        let isAdRemoved = settingRepository.isAdRemoved()
        uiState = MeterUiState(
            currentCost: costInfo.costBase,
            costCounter: costInfo.distBase,
            currentSpeedKph: 0.0,
            totalDistanceMeters: 0.0,
            meterStatus: .notRunning,
            isCityRate: false,
            isNightRate: false,
            animationFrames: frames,
            isAdRemoved: isAdRemoved
        )
    }
}
