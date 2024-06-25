//
//  TripDetailPackingGaugeRowView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import SwiftData

struct TripDetailPackingGaugeRowView: View {
    let trip: Trip
    
    var body: some View {
        HStack {
            ForEach(ListType.allCases, id: \.rawValue) { listType in
                if trip.getTotalItems(for: listType) > 0 {
                    TripDetailPackingProgressView(
                        val: Double(trip.getCompleteItems(for: listType)),
                        total: Double(trip.getTotalItems(for: listType)),
                        image: PackingList.icon(listType: listType)
                    )
                    .onChange(of: trip.getTotalItems(for: listType)) {
                        print(trip.getCompleteItems(for: listType), trip.getTotalItems(for: listType))
                    }
                    .padding(.horizontal)
                }
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    TripDetailPackingGaugeRowView(trip: trips.first!)
}
