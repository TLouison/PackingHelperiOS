//
//  TripListRowView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import SwiftUI
import MapKit

struct TripListRowView: View {
    @Binding var path: [Trip]
    
    var trip: Trip
    var height: Int
 
    @ViewBuilder private func dateInfo() -> some View {
        trip.getStatusLabel()
            .font(.caption)
            .transition(
                .symbolEffect(.disappear)
                .combined(with: .push(from: .bottom))
                .animation(.easeInOut)
            )
        
        
        if trip.status == .upcoming || trip.status == .departing {
            Text(trip.beginDate.formatted(date: .abbreviated, time: .omitted))
        }
        else if trip.status == .returning || trip.status == .complete {
            Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
        }
    }
    
    @ViewBuilder func tripRowOverlay(_ trip: Trip) -> some View {
        if height < 100 {
            HStack {
                Text(trip.name)
                    .font(.headline)
                    .padding()
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                
                Spacer()
            
                VStack(alignment: .trailing) {
                    dateInfo()
                }
                .font(.headline)
                .padding()
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }  else {
            VStack {
                HStack {
                    Spacer()
                    Text(trip.name)
                        .font(.headline)
                        .padding()
                        .background(.thickMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        dateInfo()
                    }
                    .font(.headline)
                    .padding()
                    .background(.thickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
            }
        }
    }
    
    var body: some View {
        Map(
            initialPosition: trip.destination?.mapCameraPosition ?? TripDestination.sampleData.mapCameraPosition,
            interactionModes: []
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay {
            tripRowOverlay(trip)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .onTapGesture {
            path.append(trip)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadow(radius: 4)
    }
}

//#Preview {
//    TripListRowView()
//}
