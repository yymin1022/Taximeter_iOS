//
//  HistoryViewModel.swift
//  TaxiMeter
//

import Combine
import Foundation

public final class HistoryViewModel: ObservableObject {
    @Published public var uiState: HistoryUiState = HistoryUiState()

    private let meterHistoryRepository: MeterHistoryRepository
    private var historyObservationTask: Task<Void, Never>?

    public init(meterHistoryRepository: MeterHistoryRepository = RepositoryProvider.shared.meterHistoryRepository) {
        self.meterHistoryRepository = meterHistoryRepository
        loadHistories()
    }

    deinit {
        historyObservationTask?.cancel()
    }

    /// Load driving histories from repository
    private func loadHistories() {
        historyObservationTask?.cancel()
        historyObservationTask = Task { @MainActor [weak self] in
            guard let self = self else { return }
            for await histories in self.meterHistoryRepository.getAllHistories() {
                guard !Task.isCancelled else { break }
                let totalCount = histories.count
                let totalCost = histories.reduce(Int64(0)) { $0 + Int64($1.cost) }
                let totalDistance = histories.reduce(0.0) { $0 + $1.distanceMeters }

                self.uiState = HistoryUiState(
                    isLoading: false,
                    histories: histories,
                    totalCount: totalCount,
                    totalCost: totalCost,
                    totalDistanceMeters: totalDistance,
                    showClearAllConfirm: self.uiState.showClearAllConfirm
                )
            }
        }
    }

    /// Delete single driving history by ID
    public func deleteHistory(id: Int64) {
        Task {
            await meterHistoryRepository.deleteHistory(id: id)
        }
    }

    /// Delete all driving histories
    public func deleteAllHistories() {
        Task { [weak self] in
            guard let self = self else { return }
            await self.meterHistoryRepository.deleteAllHistories()
            await MainActor.run {
                self.hideClearAllConfirm()
            }
        }
    }

    /// Show clear all confirm dialog
    public func showClearAllConfirm() {
        uiState.showClearAllConfirm = true
    }

    /// Hide clear all confirm dialog
    public func hideClearAllConfirm() {
        uiState.showClearAllConfirm = false
    }
}
