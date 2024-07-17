//
//  IAPManager.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/16/24.
//

import SwiftUI
import RevenueCat

let REVENUECAT_PUBLIC_API_KEY = "appl_oygxfOEAnjsrYdUZxXrUbxyGblx"

enum IAPPackageID: String {
    case annual_subscription = "FY2X7BQ9", monthly_subscription = "4HT3JM8D"
}

@Observable
class IAPManager {
    static let shared = IAPManager()

    var inPaymentProgress = false

    init() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: REVENUECAT_PUBLIC_API_KEY)
//        Purchases.shared.offerings { (offerings, _) in
//            if let packages = offerings?.current?.availablePackages {
//                self.packages = packages
//            }
//        }
    }

//    func purchase(product: Purchases.Package) {
//        guard !inPaymentProgress else { return }
//        inPaymentProgress = true
//        Purchases.shared.purchasePackage(product) { (_, purchaserInfo, _, _) in
//            self.inPaymentProgress = false
//        }
//    }
}
