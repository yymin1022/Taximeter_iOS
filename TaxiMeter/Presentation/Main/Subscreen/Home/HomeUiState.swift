//
//  HomeUiState.swift
//  TaxiMeter
//

import Foundation

/// UI State for HomeViewModel
public struct HomeUiState: Equatable {
    public var toastMessage: String?

    public init(toastMessage: String? = nil) {
        self.toastMessage = toastMessage
    }
}
