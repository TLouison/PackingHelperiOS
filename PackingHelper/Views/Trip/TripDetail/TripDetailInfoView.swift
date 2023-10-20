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
        VStack {
            HStack {
                Text("Trip Info")
                    .font(.title)
                Spacer()
            }
            
            Divider()
            
            Group {
                HStack {
                    Text("Duration")
                        .font(.caption)
                    Text("\(trip.duration) days")
                }
                .padding()
                .background(.thickMaterial)
                .clipShape(.capsule)
                .shadow(radius: 4)
                
                HStack {
                    Text("Added on")
                        .font(.caption)
                    Text("\(trip.createdDate.formatted(date: .abbreviated, time: .omitted))")
                }
                .padding()
                .background(.thickMaterial)
                .clipShape(.capsule)
                .shadow(radius: 4)
                
                HStack {
                    Text("Status")
                        .font(.caption)
                    trip.getStatusLabel()
                }
                .padding()
                .background(.thickMaterial)
                .clipShape(.capsule)
                .shadow(radius: 4)
            }
        }
        .roundedBox()
    }
}

//#Preview {
//    TripDetailInfoView()
//}
