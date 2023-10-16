//
//  PreviewContainer.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import SwiftData

@MainActor
let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Trip.self, TripDestination.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        let modelContext = container.mainContext
        if try modelContext.fetch(FetchDescriptor<Trip>()).isEmpty { container.mainContext.insert(Trip.sampleTrip)
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

