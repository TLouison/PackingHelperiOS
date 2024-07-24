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
    
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @State private var showOnboarding = false
    
    var body: some View {
        TabView {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane.departure")
                }
            
            DefaultPackingListView()
                .tabItem {
                    Label("Lists", systemImage: suitcaseIcon)
                }
            
            UserListView()
                .tabItem {
                    Label("Packers", systemImage: "person.circle")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .task {
            showOnboarding = !hasLaunchedBefore
        }
        .sheet(isPresented: $showOnboarding) {
            NewUserOnboardingView()
                .interactiveDismissDisabled()
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
    ContentView()
}
