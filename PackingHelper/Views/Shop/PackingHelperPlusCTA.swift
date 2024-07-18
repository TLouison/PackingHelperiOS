//
//  PackingHelperPlusCTA.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/16/24.
//

import SwiftUI

struct PackingHelperPlusCTA: View {
    enum CTAVersion {
        case small, tall
    }
    
    @Environment(PurchaseManager.self) private var purchaseManager: PurchaseManager
    
    @State private var showingStoreSheet: Bool = false
    
    let showAfterPurchase: Bool = false
    let headerText: String
    
    var version: CTAVersion = .small
    
    var smallCTA: some View {
        Group {
            if purchaseManager.hasUnlockedPlus && showAfterPurchase {
                VStack {
                    Text("Thanks for subscribing to")
                    plusSubscriptionName()
                    
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
                    plusLogoImage(size: 32)
                    
                    VStack {
                        plusSubscriptionHeader(header: headerText)
                        
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
    }
    
    var tallCTA: some View {
        Group {
            if purchaseManager.hasUnlockedPlus && showAfterPurchase {
                VStack {
                    Text("Thanks for subscribing to")
                    plusSubscriptionName()
                    
                    Button("View Your Subscription") {
                        showingStoreSheet.toggle()
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                    .background(.thickMaterial)
                    .rounded()
                }
            } else {
                VStack {
                    plusLogoImage(size: 100)

                    Spacer()
                    
                    VStack(spacing: 16) {
                        plusSubscriptionHeader(header: headerText)
                        
                        plusSubscriptionBenefits()
                    }
                    
                    Spacer()
                    
                    Button("Learn More") {
                        showingStoreSheet.toggle()
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.thickMaterial)
                    .rounded()
                    .contentShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                }
                .frame(maxWidth: .infinity)
                .padding(.top, 50)
            }
        }
        .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    var ctaView: some View {
        switch version {
            case .small: smallCTA
            case .tall: tallCTA
        }
    }
    
    var body: some View {
        ctaView
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

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    PackingHelperPlusCTA(headerText: "Small CTA", version: .small)
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    PackingHelperPlusCTA(headerText: "Tall CTA", version: .tall)
}
