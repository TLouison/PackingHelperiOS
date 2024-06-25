//
//  SettingsView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) var modelContext
    
    var body: some View {
        NavigationStack {
                VStack {
                    PackingHelperPlusPurchaseView()
                        .roundedBox()
                        .shaded()
                        .overlay(
                            RoundedRectangle(cornerRadius: defaultCornerRadius)
                                .strokeBorder(defaultLinearGradient)
                        )
                        .padding()
                    
                    SettingsFormView(preferences: Preferences.instance(with: modelContext))
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
