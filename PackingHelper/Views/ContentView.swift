//
//  ContentView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var showOnboarding = false
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane.departure")
                }
                .tag(0)
            
            DefaultPackingListView()
                .tabItem {
                    Label("Templates", systemImage: suitcaseIcon)
                }
                .tag(1)
            
            if FeatureFlags.showingMultiplePackers {
                UserGridView()
                    .tabItem {
                        Label("Packers", systemImage: "person.circle")
                    }
                    .tag(2)
            }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(3)
        }
        .sheet(isPresented: .constant(!hasCompletedOnboarding), content: {
            OnboardingContainerView(modelContext: modelContext)
                .interactiveDismissDisabled()
        })
    }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
    ContentView()
}
