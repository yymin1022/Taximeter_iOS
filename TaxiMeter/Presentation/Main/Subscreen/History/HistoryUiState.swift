//
//  HistoryUiState.swift
//  TaxiMeter
//

import Foundation

/// UI State for HistoryViewModel
public struct HistoryUiState: Equatable {
    public var isLoading: Bool
    public var histories: [MeterHistory]
    public var totalCount: Int
    public var totalCost: Int64
    public var totalDistanceMeters: Double
    public var showClearAllConfirm: Bool

    public init(
        isLoading: Bool = true,
        histories: [MeterHistory] = [],
        totalCount: Int = 0,
        totalCost: Int64 = 0,
        totalDistanceMeters: Double = 0.0,
        showClearAllConfirm: Bool = false
    ) {
        self.isLoading = isLoading
        self.histories = histories
        self.totalCount = totalCount
        self.totalCost = totalCost
        self.totalDistanceMeters = totalDistanceMeters
        self.showClearAllConfirm = showClearAllConfirm
    }
}
