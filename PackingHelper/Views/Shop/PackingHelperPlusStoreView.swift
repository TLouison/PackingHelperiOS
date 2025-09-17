//
//  PackingHelperPlusStoreView.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/16/24.
//

import SwiftUI
import StoreKit

struct PackingHelperPlusStoreView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    var body: some View {
        SubscriptionStoreView(groupID: purchaseManager.subscriptionGroupId) {
            VStack(spacing: 16) {
                Rectangle().fill(Color.red)
                plusLogoImage(size: 100)
                
                plusSubscriptionHeader()
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .bold()
                
                Text("Unlock new ways to improve your packing!")
                    .font(.subheadline.weight(.medium))
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                plusSubscriptionBenefits()
            }
            .padding()
        }
        .subscriptionStoreButtonLabel(.multiline)
        .storeButton(.visible, for: .restorePurchases)
        .onInAppPurchaseStart { product in
            try? await purchaseManager.purchase(product)
        }
        .onInAppPurchaseCompletion { _,_ in
            dismiss()
        }
    }
}

#Preview {
    PackingHelperPlusStoreView()
}
