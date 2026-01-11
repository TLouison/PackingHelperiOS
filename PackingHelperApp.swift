//
//  PackingHelperApp.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import SwiftData
import RevenueCat

@main
struct PackingHelperApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("hasLaunchedBefore") private var hasLaunchedBefore = false
    @AppStorage("hasMigratedDayOfLists") private var hasMigratedDayOfLists = false

    @Environment(\.scenePhase) var scenePhase
    
//    private var purchaseManager = PurchaseManager()
    
    let modelContainer: ModelContainer
    
    init() {
        do {
            modelContainer = try ModelContainer(for: Trip.self, TripLocation.self, PackingList.self, Item.self/*, Preferences.self*/)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }

        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: REVENUECAT_PUBLIC_API_KEY)

        // Perform data migration if needed
        if !hasMigratedDayOfLists {
            migrateDayOfLists()
        }
    }

    private func migrateDayOfLists() {
        let context = modelContainer.mainContext

        // Fetch all lists that were typed as dayOf
        // Since we changed the enum, we need to check the raw stored value
        let descriptor = FetchDescriptor<PackingList>()
        if let lists = try? context.fetch(descriptor) {
            for list in lists {
                // If the stored type was "Day-of", convert to packing with isDayOf = true
                if list.typeString == "Day-of" {
                    list.type = .packing
                    list.isDayOf = true
                }
            }
            try? context.save()
        }

        hasMigratedDayOfLists = true
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
//                .environment(purchaseManager)
//                .task {
//                    await purchaseManager.updatePurchasedProducts()
//                }
        }
        .modelContainer(modelContainer)
    }
}
