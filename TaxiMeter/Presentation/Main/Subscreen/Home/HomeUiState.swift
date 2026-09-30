//
//  HomeUiState.swift
//  TaxiMeter
//

import Foundation

/// UI State for HomeViewModel
public struct HomeUiState: Equatable {
    public var toastMessage: String?
    public var homeCaption: String?

    public init(
        toastMessage: String? = nil,
        homeCaption: String? = nil
    ) {
        self.toastMessage = toastMessage
        self.homeCaption = homeCaption
    }
}
