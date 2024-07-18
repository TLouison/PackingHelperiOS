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
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    
    @Environment(\.scenePhase) var scenePhase
    
    private var purchaseManager = PurchaseManager()
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Trip.self, TripLocation.self, PackingList.self, Item.self/*, Preferences.self*/)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environment(purchaseManager)
                .task {
                    await purchaseManager.updatePurchasedProducts()
                }
        }
        .modelContainer(modelContainer)
    }
}
