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
                HStack {
                    Spacer()
                    Text(trip.name)
                        .font(.headline)
                        .roundedBox()
                }
                Spacer()
                HStack {
                    Spacer()
                    VStack(alignment: .trailing) {
                        dateInfo()
                    }
                    .font(.headline)
                    .roundedBox()
                }
            }
            
            HStack {
                Text(trip.name)
                    .font(.headline)
                    .roundedBox()
                
                Spacer()
            
                VStack(alignment: .trailing) {
                    dateInfo()
                }
                .font(.headline)
                .roundedBox()
            }
        }
    }
    
    var body: some View {
        Map(
            position: $mapPosition,
            interactionModes: []
        )
        .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
        .overlay {
            tripRowOverlay(trip)
                .frame(maxWidth: .infinity)
                .padding()
        }
        .onTapGesture {
            path.append(trip)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .shadow(radius: defaultShadowRadius)
        .onAppear {
            mapPosition = trip.destination?.mapCameraPosition ?? TripLocation.sampleOrigin.mapCameraPosition
        }
        .padding(.vertical)
    }
}

//#Preview {
//    TripListRowView()
//}
