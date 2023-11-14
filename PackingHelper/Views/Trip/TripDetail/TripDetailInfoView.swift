//
//  TripDetailInfoView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/19/23.
//

import SwiftUI

struct TripDetailInfoView: View {
    let trip: Trip
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Trip Info")
                    .font(.title)
                Spacer()
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 20) {
                HStack {
                    Text("Status")
                        .font(.caption)
                    Spacer()
                    trip.getStatusLabel()
                }
                
                HStack {
                    Text("Duration")
                        .font(.caption)
                    Spacer()
                    Text("\(trip.duration) days")
                }
                
                HStack {
                    Text("Days to Departure")
                        .font(.caption)
                    Spacer()
                    Text("\(trip.daysUntilDeparture) days")
                }
                
                HStack {
                    Text("Added on")
                        .font(.caption)
                    Spacer()
                    Text("\(trip.createdDate.formatted(date: .abbreviated, time: .omitted))")
                }
            }
            .padding(.top)
        }
        .roundedBox()
    }
}

//#Preview {
//    TripDetailInfoView()
//}
