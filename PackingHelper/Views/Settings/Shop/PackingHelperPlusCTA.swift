//
//  PackingHelperPlusCTA.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/16/24.
//

import SwiftUI

struct PackingHelperPlusCTA: View {
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @State private var showingStoreSheet: Bool = false
    
    let showAfterPurchase: Bool = false
    let headerText: String
    
    var body: some View {
        Group {
            if purchaseManager.hasUnlockedPlus && showAfterPurchase {
                VStack {
                    Text("Thanks for subscribing to")
                    purchaseManager.plusSubscriptionName()
                    
                    Button("View Your Subscription") {
                        showingStoreSheet.toggle()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(.thickMaterial)
                    .rounded()
                }
            } else {
                HStack {
                    purchaseManager.plusLogoImage(size: 32)
                    
                    VStack {
                        purchaseManager.plusSubscriptionHeader(header: headerText)
                        
                        Button("Learn More") {
                            showingStoreSheet.toggle()
                        }
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                        .background(.thickMaterial)
                        .rounded()
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(maxWidth: .infinity)
        .roundedBox()
        .shaded()
        .overlay(
            RoundedRectangle(cornerRadius: defaultCornerRadius)
                .strokeBorder(defaultLinearGradient)
        )
        .transition(.move(edge: .top))
        .padding()
        .sheet(isPresented: $showingStoreSheet) {
            PackingHelperPlusStoreView()
        }
    }
}
//
//#Preview {
//    PackingHelperPlusCTA()
//}
