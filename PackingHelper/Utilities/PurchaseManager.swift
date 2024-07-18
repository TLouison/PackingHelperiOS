//
//  PurchaseManager.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/16/24.
//

import SwiftUI
import StoreKit
import RevenueCat

let REVENUECAT_PUBLIC_API_KEY = "appl_oygxfOEAnjsrYdUZxXrUbxyGblx"

@MainActor
@Observable
class PurchaseManager {
    let subscriptionGroupId = "21511922"
    private let productIds: [String] = [
        "FY2X7BQ9", // Annual Subscription
        "4HT3JM8D" // Monthly Subscription
    ]

    private var products: [Product] = []
    private(set) var purchasedProductIDs = Set<String>()
    
    private var productsLoaded = false
    
    private var updates: Task<Void, Never>? = nil
    
    init() {
        updates = observeTransactionUpdates()
    }

    func loadProducts() async throws {
        guard !self.productsLoaded else { return }
        self.products = try await Product.products(for: productIds)
        self.productsLoaded = true
    }
    
    func purchase(_ product: Product) async throws {
        let result = try await product.purchase()

        switch result {
        case let .success(.verified(transaction)):
            // Successful purhcase
            await transaction.finish()
            await self.updatePurchasedProducts()
        case let .success(.unverified(_, error)):
            // Successful purchase but transaction/receipt can't be verified
            // Could be a jailbroken phone
            break
        case .pending:
            // Transaction waiting on SCA (Strong Customer Authentication) or
            // approval from Ask to Buy
            break
        case .userCancelled:
            // ^^^
            break
        @unknown default:
            break
        }
    }
    
    func updatePurchasedProducts() async {
       for await result in Transaction.currentEntitlements {
           guard case .verified(let transaction) = result else {
               continue
           }

           if transaction.revocationDate == nil {
               self.purchasedProductIDs.insert(transaction.productID)
           } else {
               self.purchasedProductIDs.remove(transaction.productID)
           }
       }
    }
    
    private func observeTransactionUpdates() -> Task<Void, Never> {
        Task(priority: .background) { [unowned self] in
            for await verificationResult in Transaction.updates {
                // Using verificationResult directly would be better
                // but this way works for this tutorial
                await self.updatePurchasedProducts()
            }
        }
    }
}

extension PurchaseManager {
    var hasUnlockedPlus: Bool {
        return !self.purchasedProductIDs.isEmpty
    }
}
