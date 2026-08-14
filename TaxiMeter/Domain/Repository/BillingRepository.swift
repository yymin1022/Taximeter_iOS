//
//  BillingRepository.swift
//  TaxiMeter
//

import Foundation

/// Billing Repository Interface
/// - Connect / Disconnect Billing Service
/// - Observe for Billing Purchases
/// - Query Products and Manage Purchases
public protocol BillingRepository: Sendable {
    func connect() async -> Result<Void, Error>
    func disconnect()

    func observePurchases() -> AsyncStream<Result<[BillingPurchase], Error>>

    func acknowledgePurchase(purchaseToken: String) async -> Result<Void, Error>
    func consumePurchase(purchaseToken: String) async -> Result<Void, Error>
    func queryExistingPurchases() async -> Result<[BillingPurchase], Error>
    func queryProducts(productIds: [String]) async -> Result<[BillingProduct], Error>
}
