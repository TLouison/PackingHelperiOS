//
//  SettingsStoreView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
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
    @State private var isShowingMoreInfo: Bool = false
    
    @StateObject private var store = Store()
    
    var body: some View {
        VStack {
            if !store.products.isEmpty {
                ProductView(store.products.first!, prefersPromotionalIcon: true) {
                    Image(systemName: "plus.square.dashed")
                        .resizable()
                        .padding(10)
                        .foregroundStyle(defaultLinearGradient)
                }
                .productViewStyle(.compact)
                
                Button("Learn More") {
                    withAnimation {
                        isShowingMoreInfo.toggle()
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .background(.thickMaterial)
                .clipShape(.capsule)
                
                if isShowingMoreInfo {
                    VStack(alignment: .leading) {
                        Text("• Add unlimited users")
                        Text("• Intelligent Categorization")
                        Text("• Share lists with friends and family")
                    }
                    .roundedBox(background: .thickMaterial)
                }
            }
        }
        .roundedBox()
        .shaded()
        .overlay(
            RoundedRectangle(cornerRadius: defaultCornerRadius)
                .strokeBorder(defaultLinearGradient)
        )
        .padding()
        .task {
            await store.fetchProducts()
        }
    }
}

#Preview {
    PackingHelperPlusPurchaseView()
}
