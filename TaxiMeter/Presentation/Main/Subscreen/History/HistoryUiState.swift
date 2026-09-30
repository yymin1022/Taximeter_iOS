//
//  HistoryUiState.swift
//  TaxiMeter
//

import Foundation

/// UI State for HistoryViewModel
public struct HistoryUiState: Equatable {
    public var isLoading: Bool

    public init(isLoading: Bool = true) {
        self.isLoading = isLoading
    }
}
