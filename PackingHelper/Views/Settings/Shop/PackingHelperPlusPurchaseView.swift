//
//  SettingsStoreView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import RevenueCat
import StoreKit

@MainActor final class Store: ObservableObject {
    @Published private(set) var products: [Product] = []
    
    init() {}
    
    func fetchProducts() async {
        do {
            products = try await Product.products(
                for: ["J4P7QR9Z"]
            )
        } catch {
            products = []
        }
    }
}

struct PackingHelperPlusPurchaseView: View {
    let productIds = ["J4P7QR9Z"]

    @State private var products: [Product] = []
    
    @State private var showStoreSheet = false
    
    var subscriptionName: some View {
        HStack {
            Text("Packing Helper")
            Image(systemName: "plus.diamond.fill")
                .symbolRenderingMode(.palette)
                .foregroundStyle(.white, defaultLinearGradient)
                .padding(.leading, -5)
        }
        .font(.headline)
        .bold()
    }
    
    var subscriptionHeader: some View {
        VStack {
            Text("Subscribe to")
                .font(.subheadline)
                .fontWeight(.light)
            
            subscriptionName
        }
    }
    
    
    func logoImage(size: CGFloat) -> some View {
        Image(systemName: "suitcase.rolling.fill")
            .resizable()
            .scaledToFit()
            .foregroundStyle(defaultLinearGradient)
            .frame(width: size, height: size)
            .roundedBox(background: .thinMaterial)
            .borderGradient()
    }
    
    var body: some View {
        HStack {
                logoImage(size: 32)
                
            VStack {
                subscriptionHeader
                
                Button("Learn More") {
                    showStoreSheet.toggle()
                }
                .padding(.horizontal)
                .background(.thickMaterial)
                .rounded()
            }
            .frame(maxWidth: .infinity)
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
            SubscriptionStoreView(groupID: "BC638E58") {
                VStack(spacing: 16) {
                    logoImage(size: 100)
                    
                    subscriptionHeader
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .bold()
                    
                    Text("Unlock new ways to improve your packing!")
                        .font(.subheadline.weight(.medium))
                        .fontDesign(.rounded)
                        .multilineTextAlignment(.center)
                        .foregroundStyle(.secondary)
                }
                .padding()
            }
            .subscriptionStoreButtonLabel(.multiline)
            .storeButton(.visible, for: .restorePurchases)
        }
    }
    
    private func loadProducts() async throws {
        self.products = try await Product.products(for: productIds)
    }
    
    private func purchase(_ product: Product) async throws {
        let result = try await product.purchase()
        
        switch result {
            case let .success(.verified(transaction)):
                // Successful purhcase
                await transaction.finish()
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
}

#Preview {
    PackingHelperPlusPurchaseView()
}
