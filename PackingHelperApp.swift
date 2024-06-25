//
//  PackingHelperApp.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import SwiftData

@main
struct PackingHelperApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
        }
        .modelContainer(for: [Trip.self, TripLocation.self, PackingList.self, Item.self, Preferences.self])
    }
}
