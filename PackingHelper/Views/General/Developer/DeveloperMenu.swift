//
//  DeveloperMenu.swift
//  PackingHelper
//
//  Created by Todd Louison on 1/1/25.
//

import SwiftUI
import SwiftData

struct DeveloperMenuView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @Query private var users: [User]
    @State private var featureFlagsExpanded = true
    @State private var featureFlags = FeatureFlags.shared

    var body: some View {
        NavigationStack {
            List {
                Section {
                    DisclosureGroup("Feature Flags", isExpanded: $featureFlagsExpanded) {
                        Toggle("Recommendations", isOn: $featureFlags.showingRecommendations)
                        Toggle("Multiple Packers", isOn: $featureFlags.showingMultiplePackers)
                        Toggle("Subscription UI", isOn: $featureFlags.showingSubscription)
                        Toggle("Notifications", isOn: $featureFlags.showingNotifications)
                    }
                } footer: {
                    Text("Enable or disable experimental features for testing.").font(.subheadline)
                }

                Section {
                    Button("Reset Onboarding State") {
                        hasCompletedOnboarding = false
                        users.forEach { modelContext.delete($0) }
                        try? modelContext.save()
                        dismiss()
                    }
                } header: {
                    Text("Reset Onboarding")
                } footer: {
                    Text("Resetting onboarding state will wipe out all trips and users. Be sure you want to do this, it cannot be undone.").font(.subheadline)
                }

                Section("Debug Info") {
                    LabeledContent("Onboarding Completed") {
                        Text(hasCompletedOnboarding ? "Yes" : "No")
                    }
                    if let user = users.first {
                        LabeledContent("User Name") { Text(user.name) }
                        LabeledContent("Favorite Color") { Text(user.colorHex) }
                    }
                }
            }
            .navigationTitle("Developer Menu")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DeveloperMenuView()
}
