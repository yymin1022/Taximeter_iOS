//
//  HomeViewModel.swift
//  TaxiMeter
//

import Combine
import Foundation
import SwiftUI

public final class HomeViewModel: ObservableObject {
    @Published public var uiState: HomeUiState = HomeUiState()

    private let meterHistoryRepository: MeterHistoryRepository
    private let updateCostInfoUseCase: UpdateCostInfoUseCase
    private var historyObservationTask: Task<Void, Never>?
    private var hasCheckedUpdate: Bool = false

    private static let minHistoryCountForStats = 3

    public init(
        meterHistoryRepository: MeterHistoryRepository = RepositoryProvider.shared.meterHistoryRepository,
        updateCostInfoUseCase: UpdateCostInfoUseCase = UseCaseProvider.shared.updateCostInfoUseCase
    ) {
        self.meterHistoryRepository = meterHistoryRepository
        self.updateCostInfoUseCase = updateCostInfoUseCase
        loadHistoryCaption()
    }

    deinit {
        historyObservationTask?.cancel()
    }

    /// Load driving histories and select random home caption
    private func loadHistoryCaption() {
        historyObservationTask?.cancel()
        historyObservationTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            for await histories in self.meterHistoryRepository.getAllHistories() {
                guard !Task.isCancelled else { break }
                let totalCount = histories.count
                let totalCost = histories.reduce(Int64(0)) { $0 + Int64($1.cost) }
                let totalDistanceKm = histories.reduce(0.0) { $0 + $1.distanceMeters } / 1000.0

                var candidates: [String] = []

                // 1. Safe drive (Always included)
                candidates.append(NSLocalizedString("Have a safe drive to your destination today!", comment: ""))

                // 2. Statistics captions (When totalCount >= 3)
                if totalCount >= Self.minHistoryCountForStats {
                    // Distance
                    let distanceFormat = NSLocalizedString("Traveled %.1f km so far!", comment: "")
                    candidates.append(String(format: distanceFormat, totalDistanceKm))

                    // Cost
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .decimal
                    let formattedCost = formatter.string(from: NSNumber(value: totalCost)) ?? "\(totalCost)"
                    let costFormat = NSLocalizedString("Calculated ₩%@ in total fares with TaxiMeter!", comment: "")
                    candidates.append(String(format: costFormat, formattedCost))

                    // Trip count
                    let tripsFormat = NSLocalizedString("Ready for trip #%d!", comment: "")
                    candidates.append(String(format: tripsFormat, totalCount + 1))
                }

                let selectedCaption = candidates.randomElement()
                self.uiState.homeCaption = selectedCaption
            }
        }
    }

    /// Clear Toast Message
    public func clearToast() {
        uiState.toastMessage = nil
    }

    /// Check and apply cost info update (executed only once per app session)
    public func updateCostInfo() {
        guard !hasCheckedUpdate else { return }
        hasCheckedUpdate = true

        Task { @MainActor in
            let updateResult = await updateCostInfoUseCase.execute()
            switch updateResult {
            case .canceled, .upToDate:
                break
            case .success:
                self.uiState.toastMessage = "Cost info is updated."
            case .failure:
                self.uiState.toastMessage = "Cost info update failed. Please check network state."
            }
        }
    }
}
