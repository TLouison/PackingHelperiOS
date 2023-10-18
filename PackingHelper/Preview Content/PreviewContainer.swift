//
//  PreviewContainer.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import Foundation
import SwiftData

let previewContainer: ModelContainer = {
    do {
        let container = try ModelContainer(
            for: Trip.self, TripDestination.self, PackingList.self, Item.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        
        Task { @MainActor in
            let context = container.mainContext
            
            let destination = TripDestination.sampleData
            context.insert(destination)
            context.insert(Trip(name: "NYC", beginDate: Date.now, endDate: Date.now, destination: destination))
        }
        return container
    } catch {
        fatalError("Failed to create container")
    }
}()

