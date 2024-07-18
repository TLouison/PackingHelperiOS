//
//  SettingsView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            VStack {
                PackingHelperPlusCTA(headerText: "Subscribe to", showAfterPurchase: true)
                
                SettingsFormView()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Settings")
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    SettingsView()
}
