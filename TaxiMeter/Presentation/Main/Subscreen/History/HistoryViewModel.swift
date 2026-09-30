//
//  HistoryViewModel.swift
//  TaxiMeter
//

import Combine
import Foundation

public final class HistoryViewModel: ObservableObject {
    @Published public var uiState: HistoryUiState = HistoryUiState()

    public init() {}
}
