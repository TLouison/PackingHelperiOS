//
//  SettingsStoreView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import RevenueCat
import StoreKit

struct PackingHelperPlusPurchaseView: View {
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @State private var showStoreSheet = false
    
    var body: some View {
        Group {
            if purchaseManager.hasUnlockedPlus {
                VStack {
                    Text("Thanks for subscribing to")
                    purchaseManager.plusSubscriptionName()
                    
                    Button("View Your Subscription") {
                        showStoreSheet.toggle()
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
                        purchaseManager.plusSubscriptionHeader()
                        
                        Button("Learn More") {
                            showStoreSheet.toggle()
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
        .sheet(isPresented: $showStoreSheet) {
            PackingHelperPlusStoreView()
        }
    }
}

//#Preview {
//    PackingHelperPlusPurchaseView()
//}
