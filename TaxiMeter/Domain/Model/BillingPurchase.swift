//
//  BillingPurchase.swift
//  TaxiMeter
//

import Foundation

public enum PurchaseState: Sendable, Equatable {
    case purchased
    case pending
    case unspecified
}

/// Billing Purchase Data Model
public struct BillingPurchase: Equatable, Sendable {
    public let orderID: String?
    public let productIDs: [String]
    public let purchaseToken: String
    public let state: PurchaseState
    public let isAcknowledged: Bool

    public init(
        orderID: String?,
        productIDs: [String],
        purchaseToken: String,
        state: PurchaseState,
        isAcknowledged: Bool
    ) {
        self.orderID = orderID
        self.productIDs = productIDs
        self.purchaseToken = purchaseToken
        self.state = state
        self.isAcknowledged = isAcknowledged
    }
}
