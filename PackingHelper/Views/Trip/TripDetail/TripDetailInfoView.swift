//
//  TripDetailInfoView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/19/23.
//

import SwiftUI

struct TripDetailInfoView: View {
    let trip: Trip
    
    @ViewBuilder
    func infoRow(_ title: String, _ detail: some View) -> some View {
        HStack {
            Text(title).font(.caption)
            Spacer()
            detail
        }
    }
    
    var body: some View {
        TripDetailSectionView(title: "Trip Info") {
            VStack(spacing: 10) {
                infoRow("Status", trip.getStatusLabel())
                infoRow("Type", trip.getTypeLabel())
                infoRow("Duration", Text("\(trip.duration) days"))
                
                if trip.daysUntilDeparture > 0 {
                    infoRow("Days Until Departure", Text("\(trip.daysUntilDeparture) days"))
                } else if trip.daysUntilReturn > 0 {
                    infoRow("Days Until Return", Text("\(trip.daysUntilReturn) days"))
                }
                
                infoRow("Added On", Text("\(trip.createdDate.formatted(date: .abbreviated, time: .omitted))"))
            }
        }
    }
}

//#Preview {
//    TripDetailInfoView()
//}
