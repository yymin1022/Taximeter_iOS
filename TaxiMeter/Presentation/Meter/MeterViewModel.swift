//
//  MeterViewModel.swift
//  TaxiMeter
//

import Foundation
import Observation
import CoreLocation
import UIKit

@Observable
public final class MeterViewModel {
    public var uiState: MeterUiState = MeterUiState()

    private let settingRepository: SettingRepository
    private let costRepository: CostRepository
    private let calculateMeterCostUseCase: CalculateMeterCostUseCase
    private let locationManager = CLLocationManager()

    private var meterCalculationTask: Task<Void, Never>?
    private var cityRateContinuation: AsyncStream<Bool>.Continuation?

    public init(
        settingRepository: SettingRepository = RepositoryProvider.shared.settingRepository,
        costRepository: CostRepository = RepositoryProvider.shared.costRepository,
        calculateMeterCostUseCase: CalculateMeterCostUseCase = UseCaseProvider.shared.calculateMeterCostUseCase
    ) {
        self.settingRepository = settingRepository
        self.costRepository = costRepository
        self.calculateMeterCostUseCase = calculateMeterCostUseCase

        loadAnimationFrames()
    }

    deinit {
        stopMeterInternal()
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
            startMeterCalculation()
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

        uiState.meterStatus = .running

        // Keep screen on during driving
        UIApplication.shared.isIdleTimerDisabled = true

        meterCalculationTask = Task { @MainActor in
            for await meterState in calculateMeterCostUseCase.execute(costInfo: costInfo, isCityRateStream: isCityRateStream) {
                guard !Task.isCancelled else { break }
                self.uiState.currentCost = meterState.currentCost
                self.uiState.costCounter = meterState.costCounter
                self.uiState.currentSpeedKph = meterState.currentSpeedKph
                self.uiState.totalDistanceMeters = meterState.totalDistanceMeters
                self.uiState.meterStatus = meterState.status
                self.uiState.isNightRate = meterState.isNightRate
                self.uiState.isCityRate = meterState.isCityRate
            }
        }
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

        // Restore normal screen sleep timer
        UIApplication.shared.isIdleTimerDisabled = false

        let frames = uiState.animationFrames
        uiState = MeterUiState(animationFrames: frames)
    }
}
