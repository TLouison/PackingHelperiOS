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
            ScrollView {
                VStack(spacing: 0) {
                    PackingHelperPlusCTA(headerText: "", version: .new)
                    
                    SettingsFormView()
                }
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
