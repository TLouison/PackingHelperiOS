//
//  NewUserTripsExplainer.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/23/24.
//

import SwiftUI
import MapKit

struct NewUserTripsExplainer: View {
    @State private var path: NavigationPath = .init()
    
    @ViewBuilder private func dateInfo(trip: Trip) -> some View {
        trip.getStatusLabel()
            .font(.caption)
            .transition(
                .symbolEffect(.disappear)
                .combined(with: .push(from: .bottom))
                .animation(.easeInOut)
            )
        
        
        if trip.status == .upcoming || trip.status == .departing {
            Text(trip.startDate.formatted(date: .abbreviated, time: .omitted))
        }
        else if trip.status == .returning || trip.status == .complete {
            Text(trip.endDate.formatted(date: .abbreviated, time: .omitted))
        }
    }
    
    @ViewBuilder func tripRowOverlay(_ trip: Trip) -> some View {
        ViewThatFits {
            VStack {
                HStack {
                    Spacer()
                    Text(trip.name)
                        .font(.title)
                        .roundedBox()
                        .shaded()
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        dateInfo(trip: Trip.sampleTrip)
                    }
                    .font(.headline)
                    .roundedBox()
                    .shaded()
                }
            }
            
            HStack {
                Text(trip.name)
                    .font(.headline)
                    .roundedBox()
                    .shaded()
                
                Spacer()
            
                VStack(alignment: .trailing) {
                    dateInfo(trip: Trip.sampleTrip)
                }
                .font(.headline)
                .roundedBox()
                .shaded()
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Label("Trips", systemImage: "airplane.departure")
                .font(.largeTitle)
                .padding(.bottom, 16)
            
            Text("Add trips to keep track of where you're going and when. You'll be able to attach packing lists to trips to make sure you always bring what you need!")
                .padding(.bottom, 8)
            
            // Duplicate of TripListRowView, but without dynamic data
            Map(
                position: .constant(MapCameraPosition.region(
                    MKCoordinateRegion(
                        center:  CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060),
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.5,
                            longitudeDelta: 0.5
                        )
                    )
                )),
                interactionModes: []
            )
            .frame(maxHeight: .infinity)
            .overlay {
                ZStack {
                    tripRowOverlay(Trip.sampleTrip)
                }.padding()
            }
            .rounded()
        }
    }
}

#Preview {
    NewUserTripsExplainer()
}
