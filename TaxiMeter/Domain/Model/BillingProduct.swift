//
//  BillingProduct.swift
//  TaxiMeter
//

import Foundation

/// Billing Product Data Model
public struct BillingProduct: Identifiable, Equatable, Sendable {
    public let id: String
    public let name: String
    public let description: String
    public let formattedPrice: String
    public let priceMicros: Int64

    public init(
        id: String,
        name: String,
        description: String,
        formattedPrice: String,
        priceMicros: Int64
    ) {
        self.id = id
        self.name = name
        self.description = description
        self.formattedPrice = formattedPrice
        self.priceMicros = priceMicros
    }
}
