//
//  SettingsStoreView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import StoreKit

struct PackingHelperPlusPurchaseView: View {
    @State private var isShowingMoreInfo: Bool = false
    
    var body: some View {
        VStack {
            ProductView(id: "J4P7QR9Z", prefersPromotionalIcon: true) {
                Image(systemName: "plus.square.dashed")
                    .resizable()
                    .padding()
                    .foregroundStyle(defaultLinearGradient)
            }
            .productViewStyle(.compact)
            
            Button("Learn More") {
                withAnimation {
                    isShowingMoreInfo.toggle()
                }
            }
            
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
}

#Preview {
    PackingHelperPlusPurchaseView()
}
