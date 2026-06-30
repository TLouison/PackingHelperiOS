//
//  TripDetailPackingGaugeRowView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import SwiftData
import OSLog

struct TripDetailPackingGaugeRowView: View {
    let trip: Trip

    var body: some View {
        HStack {
            let total = trip.totalItemsCount
            if total > 0 {
                TripDetailPackingProgressView(
                    val: Double(trip.packedItemsCount),
                    total: Double(total),
                    image: Image(systemName: suitcaseIcon)
                )
                .onChange(of: total) {
                    AppLogger.trip.debug("Packing progress changed: \(trip.packedItemsCount)/\(total)")
                }
                .padding(.horizontal)
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    TripDetailPackingGaugeRowView(trip: trips.first!)
}
