//
//  ProductItem.swift
//  TaxiMeter
//

import Foundation

/// Product Item UI Model
public struct ProductItem: Identifiable, Equatable, Sendable {
    public let id: String = UUID().uuidString
    public let productId: String
    public let title: String
    public let desc: String
    public let formattedPrice: String
    public let isPurchased: Bool

    public init(
        productId: String = "",
        title: String,
        desc: String,
        formattedPrice: String,
        isPurchased: Bool = false
    ) {
        self.productId = productId
        self.title = title
        self.desc = desc
        self.formattedPrice = formattedPrice
        self.isPurchased = isPurchased
    }
}
