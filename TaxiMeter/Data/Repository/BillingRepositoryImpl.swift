//
//  BillingRepositoryImpl.swift
//  TaxiMeter
//

import Foundation
import StoreKit

public final class BillingRepositoryImpl: BillingRepository, @unchecked Sendable {
    private let preferenceDataSource: PreferenceDataSource
    private var transactionTask: Task<Void, Never>?

    public init(preferenceDataSource: PreferenceDataSource) {
        self.preferenceDataSource = preferenceDataSource
        startTransactionListener()
        Task {
            await checkExistingEntitlementsOnLaunch()
        }
    }

    deinit {
        transactionTask?.cancel()
    }

    public func connect() async -> Result<Void, Error> {
        return .success(())
    }

    public func disconnect() {
        transactionTask?.cancel()
    }

    public func observePurchases() -> AsyncStream<Result<[BillingPurchase], Error>> {
        AsyncStream { continuation in
            let task = Task {
                for await result in Transaction.updates {
                    switch result {
                    case .verified(let transaction):
                        let purchase = self.mapTransactionToPurchase(transaction)
                        self.handleAdRemovalStatus(for: transaction)
                        continuation.yield(.success([purchase]))
                    case .unverified(_, let error):
                        continuation.yield(.failure(error))
                    }
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    public func acknowledgePurchase(purchaseToken: String) async -> Result<Void, Error> {
        return .success(())
    }

    public func consumePurchase(purchaseToken: String) async -> Result<Void, Error> {
        return .success(())
    }

    public func queryExistingPurchases() async -> Result<[BillingPurchase], Error> {
        var purchases: [BillingPurchase] = []
        var hasAdRemove = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                purchases.append(mapTransactionToPurchase(transaction))
                if transaction.productID == "ad_remove" && transaction.revocationDate == nil {
                    hasAdRemove = true
                }
            }
        }
        preferenceDataSource.setBoolean(key: PreferenceDefs.prefKeyAdRemove, value: hasAdRemove)
        return .success(purchases)
    }

    public func queryProducts(productIds: [String]) async -> Result<[BillingProduct], Error> {
        do {
            let storeProducts = try await Product.products(for: productIds)
            let products = storeProducts.map { mapStoreProductToBillingProduct($0) }
            return .success(products)
        } catch {
            return .failure(error)
        }
    }

    public func launchPurchase(productId: String) async -> Result<Void, Error> {
        do {
            let storeProducts = try await Product.products(for: [productId])
            guard let product = storeProducts.first else {
                let error = NSError(
                    domain: "StoreKit",
                    code: 404,
                    userInfo: [NSLocalizedDescriptionKey: "App Store에서 해당 상품(\(productId)) 정보를 찾지 못했습니다."]
                )
                return .failure(error)
            }

            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                switch verification {
                case .verified(let transaction):
                    await transaction.finish()
                    handleAdRemovalStatus(for: transaction)
                    return .success(())
                case .unverified(_, let error):
                    return .failure(error)
                }
            case .userCancelled:
                let error = NSError(domain: "BillingRepository", code: -1, userInfo: [NSLocalizedDescriptionKey: "User cancelled"])
                return .failure(error)
            case .pending:
                return .success(())
            @unknown default:
                return .success(())
            }
        } catch {
            return .failure(error)
        }
    }

    private func checkExistingEntitlementsOnLaunch() async {
        var hasAdRemove = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result {
                if transaction.productID == "ad_remove" && transaction.revocationDate == nil {
                    hasAdRemove = true
                }
            }
        }
        preferenceDataSource.setBoolean(key: PreferenceDefs.prefKeyAdRemove, value: hasAdRemove)
    }

    private func startTransactionListener() {
        transactionTask = Task {
            for await result in Transaction.updates {
                if case .verified(let transaction) = result {
                    await transaction.finish()
                    self.handleAdRemovalStatus(for: transaction)
                }
            }
        }
    }

    private func handleAdRemovalStatus(for transaction: Transaction) {
        if transaction.productID == "ad_remove" {
            let isPurchased = transaction.revocationDate == nil
            preferenceDataSource.setBoolean(key: PreferenceDefs.prefKeyAdRemove, value: isPurchased)
        }
    }

    private func mapTransactionToPurchase(_ transaction: Transaction) -> BillingPurchase {
        return BillingPurchase(
            orderID: String(transaction.id),
            productIDs: [transaction.productID],
            purchaseToken: String(transaction.id),
            state: transaction.revocationDate == nil ? .purchased : .unspecified,
            isAcknowledged: true
        )
    }

    private func mapStoreProductToBillingProduct(_ product: Product) -> BillingProduct {
        let priceMicros = Int64(truncating: NSDecimalNumber(decimal: product.price).multiplying(by: 1_000_000))
        return BillingProduct(
            id: product.id,
            name: product.displayName,
            description: product.description,
            formattedPrice: product.displayPrice,
            priceMicros: priceMicros
        )
    }
}
