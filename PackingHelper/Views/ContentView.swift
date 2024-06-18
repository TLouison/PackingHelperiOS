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
            let firstLaunch = checkIfFirstLaunch()
            if firstLaunch {
                showOnboardingScreen.toggle()
            }
        }
        .sheet(isPresented: $showOnboardingScreen) {
            NewUserOnboardingView()
        }
    }
}

#Preview {
    ContentView()
}
