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
    
    @Query private var users: [User]
    @State private var showOnboardingScreen = false
    @State private var name = ""
    
    func checkIfFirstLaunch() -> Bool {
        // Check if it's the user's first launch
        if UserDefaults.standard.bool(forKey: "isFirstLaunch") {
            // App is not the first launch
            return false
        } else {
            // First launch, set the flag
            UserDefaults.standard.set(true, forKey: "isFirstLaunch")
            return true
        }
    }
    
    func doUsersExist() -> Bool {
        return !users.isEmpty
    }
    
    var body: some View {
        TabView {
            TripListView()
                .tabItem {
                    Label("Trips", systemImage: "airplane.departure")
                }
            
            DefaultPackingListView()
                .tabItem {
                    Label("Lists", systemImage: "suitcase.rolling.fill")
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
//            Preferences.ensureExists(with: modelContext)
            if checkIfFirstLaunch() && !doUsersExist() {
                showOnboardingScreen.toggle()
            }
        }
        .sheet(isPresented: $showOnboardingScreen) {
            NewUserOnboardingView()
        }
    }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
    ContentView()
}
