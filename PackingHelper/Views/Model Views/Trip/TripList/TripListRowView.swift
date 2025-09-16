//
//  TripListRowView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import SwiftUI
import MapKit

struct TripListRowView: View {
    @Binding var path: NavigationPath
    
    @State private var mapPosition: MapCameraPosition = .automatic
    
    @Bindable var trip: Trip
    
    var disabled: Bool
 
    @ViewBuilder private func dateInfo() -> some View {
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
                HStack(alignment: .top) {
                    UserIndicators(users: trip.packers)
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
                        dateInfo()
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
                    dateInfo()
                }
                .font(.headline)
                .roundedBox()
                .shaded()
            }
        }
    }
    
    var body: some View {
        Map(
            position: $mapPosition,
            interactionModes: []
        )
        .overlay {
            ZStack {
                tripRowOverlay(trip)
                    .frame(maxWidth: .infinity)
                    .padding()
                
                
                // Block the trip from being accessed if the user has more than the free amount
                if disabled {
                    Color.black.opacity(0.8).frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                    VStack(spacing: 32) {
                        VStack {
                            Text("This Trip is Disabled").font(.title)
                            Text("You may only plan up to \(Trip.maxFreeTrips) trips.").font(.subheadline)
                        }
                        
                        VStack {
                            Text("To regain access, please:")
                                .font(.headline)
                            VStack {
                                Text("- Complete your other trips.")
                                Text("- Remove other upcoming trips.")
                                plusSubscriptionWithText(before: "- Subscribe to")
                            }
                            .font(.subheadline)
                        }
                    }
                }
            }
        }
        .onTapGesture {
            if !disabled {
                path.append(trip)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
        .shadow(radius: defaultShadowRadius)
        .onAppear {
            if let destination = trip.destination {
                mapPosition = destination.mapCameraPosition
            }
        }
        .padding(.vertical)
    }
}

struct UserIndicators: View {
    let users: [User]
    
    var body: some View {
        HStack {
            ForEach(users) { user in
                user.pillFirstInitialIconSolid
            }
        }
        .scaleEffect(1.4, anchor: .topLeading)
    }
}

//#Preview {
//    TripListRowView()
//}
