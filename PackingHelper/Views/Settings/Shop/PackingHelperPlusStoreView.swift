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
                purchaseManager.plusLogoImage(size: 100)
                
                purchaseManager.plusSubscriptionHeader()
                    .multilineTextAlignment(.center)
                    .font(.title)
                    .bold()
                
                Text("Unlock new ways to improve your packing!")
                    .font(.subheadline.weight(.medium))
                    .fontDesign(.rounded)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 8) {
                    VStack(alignment: .leading) {
                        Text("∙ Packing for Multiple Users")
                        Text("∙ AI-Assisted Packing Suggestions")
                        
                        HStack(spacing: 0) {
                            Text("∙ Collaborate With Friends and Family")
                            Text("*").bold()
                        }
                    }
                    .font(.callout)
                    
                    
                    Text("* Coming soon")
                        .font(.caption)
                        .bold()
                }
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
