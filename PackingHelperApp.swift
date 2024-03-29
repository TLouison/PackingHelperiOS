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
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Trip.self, TripDestination.self, PackingList.self, Item.self])
    }
}
