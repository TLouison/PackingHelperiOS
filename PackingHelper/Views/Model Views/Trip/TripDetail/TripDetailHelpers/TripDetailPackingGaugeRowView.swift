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
            // Regular list type gauges (non-Day-of)
            ForEach(ListType.allCases, id: \.rawValue) { listType in
                let total = trip.getTotalItems(for: listType, isDayOf: false)
                if total > 0 {
                    TripDetailPackingProgressView(
                        val: Double(trip.getCompleteItems(for: listType, isDayOf: false)),
                        total: Double(total),
                        image: PackingList.icon(listType: listType)
                    )
                    .onChange(of: total) {
                        AppLogger.trip.debug("Progress changed for \(listType.rawValue): \(trip.getCompleteItems(for: listType, isDayOf: false))/\(total)")
                    }
                    .padding(.horizontal)
                }
            }

            // Day-of gauge (combines all Day-of items)
            let dayOfTotal = trip.getTotalItems(for: .packing, isDayOf: true) +
                             trip.getTotalItems(for: .task, isDayOf: true)
            if dayOfTotal > 0 {
                TripDetailPackingProgressView(
                    val: Double(trip.getCompleteItems(for: .packing, isDayOf: true) +
                               trip.getCompleteItems(for: .task, isDayOf: true)),
                    total: Double(dayOfTotal),
                    image: "sun.horizon"
                )
                .onChange(of: dayOfTotal) {
                    let completed = trip.getCompleteItems(for: .packing, isDayOf: true) + trip.getCompleteItems(for: .task, isDayOf: true)
                    AppLogger.trip.debug("Day-of progress changed: \(completed)/\(dayOfTotal)")
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
