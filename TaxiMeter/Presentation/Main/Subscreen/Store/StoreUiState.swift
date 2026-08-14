//
//  StoreUiState.swift
//  TaxiMeter
//

import Foundation

public struct StoreUiState: Equatable {
    public var isLoading: Bool
    public var isPurchasing: Bool
    public var productItems: [ProductItem]
    public var selectedProductIdx: Int?
    public var snackBarMessage: String?

    public init(
        isLoading: Bool = true,
        isPurchasing: Bool = false,
        productItems: [ProductItem] = [],
        selectedProductIdx: Int? = nil,
        snackBarMessage: String? = nil
    ) {
        self.isLoading = isLoading
        self.isPurchasing = isPurchasing
        self.productItems = productItems
        self.selectedProductIdx = selectedProductIdx
        self.snackBarMessage = snackBarMessage
    }
}
