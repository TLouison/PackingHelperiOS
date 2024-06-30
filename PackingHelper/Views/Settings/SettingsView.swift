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
                    PackingHelperPlusPurchaseView()
                    
                    SettingsFormView(/*preferences: Preferences.instance(with: modelContext)*/)
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
