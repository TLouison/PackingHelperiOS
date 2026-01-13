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
    @AppStorage("hasMigratedSortOrders") private var hasMigratedSortOrders = false

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

        if !hasMigratedSortOrders {
            migrateSortOrders()
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

    private func migrateSortOrders() {
        let context = modelContainer.mainContext

        // Migrate Items - set initial sort orders based on creation date
        let itemDescriptor = FetchDescriptor<Item>(
            sortBy: [SortDescriptor(\.created, order: .forward)]
        )
        if let items = try? context.fetch(itemDescriptor) {
            // Group items by list for list-specific ordering
            let itemsByList = Dictionary(grouping: items) { $0.list?.persistentModelID }

            for (_, listItems) in itemsByList {
                for (index, item) in listItems.enumerated() {
                    item.sortOrder = index
                    // Generate UUID if missing (for existing items)
                    if item.uuid.uuidString == "00000000-0000-0000-0000-000000000000" {
                        item.uuid = UUID()
                    }
                }
            }

            // Set unified sort order globally
            for (index, item) in items.enumerated() {
                item.unifiedSortOrder = index
            }
        }

        // Migrate PackingLists - set initial sort orders based on creation date
        let listDescriptor = FetchDescriptor<PackingList>(
            sortBy: [SortDescriptor(\.created, order: .forward)]
        )
        if let lists = try? context.fetch(listDescriptor) {
            // Group by trip for trip-specific ordering
            let listsByTrip = Dictionary(grouping: lists) { $0.trip?.persistentModelID }

            for (_, tripLists) in listsByTrip {
                // Further group by type and isDayOf
                let grouped = Dictionary(grouping: tripLists) { "\($0.type.rawValue)-\($0.isDayOf)" }
                for (_, typeLists) in grouped {
                    for (index, list) in typeLists.enumerated() {
                        list.sortOrder = index
                        // Generate UUID if missing (for existing lists)
                        if list.uuid.uuidString == "00000000-0000-0000-0000-000000000000" {
                            list.uuid = UUID()
                        }
                    }
                }
            }
        }

        try? context.save()
        hasMigratedSortOrders = true
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
