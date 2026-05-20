//
//  IAPService.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation
import StoreKit

enum IAPServiceAlertType {
    case disabled
    case restored
    case purchased

    var message: String {
        switch self {
        case .disabled: "It looks like in-app purchases are disabled for your device."
        case .restored: "You've successfully restored your purchase!"
        case .purchased: "Your tip was received. Thank you!"
        }
    }
}

@Observable
final class IAPService {
    static let shared = IAPService()

    static let graciousTipProductID = "gracious_tip_0.99"
    static let generousTipProductID = "generous_tip_1.99"
    static let gratuitousTipProductID = "gratuitous_tip_4.99"

    private static let tipProductIDs: [String] = [
        graciousTipProductID,
        generousTipProductID,
        gratuitousTipProductID,
    ]

    private(set) var products: [Product] = []
    private(set) var purchaseStatus: IAPServiceAlertType?

    private init() {
        // The singleton lives until process exit, so these listeners run
        // for the lifetime of the app — no cancellation or weak self needed.
        Task {
            // Drain any transactions that completed while the app was killed
            // (Ask to Buy approval, family sharing, offer code redemption).
            // Transaction.updates only emits new updates while the listener
            // is alive, so this catches everything else.
            for await update in Transaction.unfinished {
                await process(transactionUpdate: update)
            }
        }

        Task {
            for await update in Transaction.updates {
                await process(transactionUpdate: update)
            }
        }
    }

    func clearPurchaseStatus() {
        purchaseStatus = nil
    }

    var canMakePayments: Bool {
        AppStore.canMakePayments
    }

    func loadProducts() async {
        do {
            let fetched = try await Product.products(for: Self.tipProductIDs)
            products = fetched.sorted { $0.price < $1.price }
        } catch {
            print("Failed to load IAPs: \(error)")
        }
    }

    func purchase(_ product: Product) async {
        guard canMakePayments else {
            purchaseStatus = .disabled
            return
        }

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if case .verified(let transaction) = verification {
                    await transaction.finish()
                    purchaseStatus = .purchased
                }

            case .userCancelled, .pending:
                break

            @unknown default:
                break
            }
        } catch {
            print("Purchase failed for \(product.id): \(error)")
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            purchaseStatus = .restored
        } catch {
            print("Failed to restore purchases: \(error)")
        }
    }

    func product(for productID: String) -> Product? {
        products.first { $0.id == productID }
    }

    func displayPrice(for productID: String) -> String? {
        product(for: productID)?.displayPrice
    }

    private func process(transactionUpdate result: VerificationResult<Transaction>) async {
        guard case .verified(let transaction) = result else { return }
        await transaction.finish()
        purchaseStatus = .purchased
    }
}
