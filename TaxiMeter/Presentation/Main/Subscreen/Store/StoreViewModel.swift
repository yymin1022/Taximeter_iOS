//
//  StoreViewModel.swift
//  TaxiMeter
//

import Combine
import Foundation
import SwiftUI

public final class StoreViewModel: ObservableObject {
    @Published public var uiState: StoreUiState = StoreUiState()

    private let billingRepository: BillingRepository

    private static let skuAdRemove = "ad_remove"
    private static let skuDonation1000 = "donation_1000"
    private static let skuDonation5000 = "donation_5000"
    private static let skuDonation10000 = "donation_10000"
    private static let skuDonation50000 = "donation_50000"

    private static let productsAcknowledgeable = [skuAdRemove]
    private static let productsConsumable = [
        skuDonation1000,
        skuDonation5000,
        skuDonation10000,
        skuDonation50000
    ]
    private static let productsAll = productsAcknowledgeable + productsConsumable

    private var currentSelectedProductID: String?
    private var productIDs: [String] = []
    private var observeTask: Task<Void, Never>?

    public init(billingRepository: BillingRepository = RepositoryProvider.shared.billingRepository) {
        self.billingRepository = billingRepository
        observePurchaseResult()
    }

    deinit {
        observeTask?.cancel()
    }

    /// Load product items, sort them (Ad removal first, then donation by price ascending), and convert to UI Item
    public func loadProducts() {
        Task { @MainActor in
            setLoading(true)

            let productsResult = await billingRepository.queryProducts(productIds: Self.productsAll)
            switch productsResult {
            case .failure:
                showSnackBar("Failed to load store data.")
            case .success(let products):
                // Sort: ad_remove at top, donation products by price micros ascending
                let sortedProducts = products.sorted { p1, p2 in
                    if p1.id == Self.skuAdRemove { return true }
                    if p2.id == Self.skuAdRemove { return false }
                    return p1.priceMicros < p2.priceMicros
                }

                self.productIDs = sortedProducts.map { $0.id }

                var purchasedProductIDs: [String] = []
                let purchasesResult = await billingRepository.queryExistingPurchases()
                if case .success(let purchases) = purchasesResult {
                    purchasedProductIDs = purchases
                        .filter { $0.state == .purchased }
                        .flatMap { $0.productIDs }
                        .filter { Self.productsAcknowledgeable.contains($0) }
                }

                let productItems = sortedProducts.map { product in
                    let isPurchased = purchasedProductIDs.contains(product.id)
                    return ProductItem(
                        productId: product.id,
                        title: product.name,
                        desc: product.description,
                        formattedPrice: product.formattedPrice,
                        isPurchased: isPurchased
                    )
                }

                uiState.productItems = productItems
            }

            setLoading(false)
        }
    }

    /// On click product item
    public func onClickProduct(idx: Int) {
        guard productIDs.indices.contains(idx) else {
            currentSelectedProductID = nil
            uiState.selectedProductIdx = nil
            return
        }

        currentSelectedProductID = productIDs[idx]
        uiState.selectedProductIdx = idx
    }

    /// On click purchase button
    public func onClickPurchase() {
        guard let productID = currentSelectedProductID else { return }

        Task { @MainActor in
            uiState.isPurchasing = true
            if let repoImpl = billingRepository as? BillingRepositoryImpl {
                let result = await repoImpl.launchPurchase(productId: productID)
                switch result {
                case .success:
                    showSnackBar("Purchase completed successfully.")
                    loadProducts()
                case .failure:
                    showSnackBar("Failed to process purchasing.")
                }
            } else {
                showSnackBar("Purchase completed successfully.")
                loadProducts()
            }
            uiState.isPurchasing = false
        }
    }

    /// Observe purchase result
    private func observePurchaseResult() {
        observeTask = Task {
            for await result in billingRepository.observePurchases() {
                await MainActor.run {
                    self.uiState.isPurchasing = false
                    switch result {
                    case .success(let purchases):
                        for purchase in purchases {
                            self.handleCompletedPurchase(purchase)
                        }
                    case .failure:
                        self.showSnackBar("Failed to process purchasing.")
                    }
                }
            }
        }
    }

    private func handleCompletedPurchase(_ purchase: BillingPurchase) {
        if purchase.state == .purchased {
            showSnackBar("Purchase completed successfully.")
            loadProducts()
        } else if purchase.state == .pending {
            showSnackBar("Purchase is currently pending.")
        }
    }

    private func setLoading(_ isLoading: Bool) {
        uiState.isLoading = isLoading
    }

    private func showSnackBar(_ message: String) {
        uiState.snackBarMessage = message
    }

    public func clearSnackBar() {
        uiState.snackBarMessage = nil
    }
}
