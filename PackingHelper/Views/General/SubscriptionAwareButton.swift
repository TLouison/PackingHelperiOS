//
//  SubscriptionAwareButton.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/16/24.
//

import SwiftUI

struct SubscriptionAwareButton<Label: View>: View {
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @State private var isShowingSubscriptionStoreSheet = false
    
    var localLimitMet: Bool
    
    var paidAction: () -> Void
    @ViewBuilder let label: () -> Label
    
    var body: some View {
            Button {
                withAnimation {
                    if purchaseManager.hasUnlockedPlus || !localLimitMet {
                        print("User is Plus, running paid action")
                        paidAction()
                    } else {
                        print("User is not subscribed, showing subscription page")
                        isShowingSubscriptionStoreSheet.toggle()
                    }
                }
            } label: {
                if !purchaseManager.hasUnlockedPlus && localLimitMet {
                    label()
                        .labelStyle(.iconOnly)
                        .overlay {
                            purchaseManager.plusSubscriptionIcon()
                                .offset(x:8, y:8)
                        }
                } else {
                    label()
                        .labelStyle(.iconOnly)
                }
            }
        .sheet(isPresented: $isShowingSubscriptionStoreSheet) {
            PackingHelperPlusStoreView()
        }
    }
}

#Preview {
    VStack(spacing: 32) {
        SubscriptionAwareButton(localLimitMet: true) {
            print("Hello!")
        } label: {
            Label("Print Hello", systemImage: "globe")
                .labelStyle(.iconOnly)
        }
        
        SubscriptionAwareButton(localLimitMet: false) {
            print("Hello!")
        } label: {
            Label("Print Hello", systemImage: "globe")
                .labelStyle(.iconOnly)
        }
    }
    .environment(PurchaseManager())
}
