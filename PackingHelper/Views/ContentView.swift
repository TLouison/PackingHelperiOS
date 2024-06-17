//
//  ContentView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI

struct ContentView: View {
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
                    Label("Users", systemImage: "person.circle")
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
    }
}

#Preview {
    ContentView()
}
