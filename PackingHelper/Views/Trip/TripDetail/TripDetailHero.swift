//
//  TripDetailHeader.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/18/23.
//

import SwiftUI
import MapKit

struct TripDetailHero: View {
    @Bindable var trip: Trip
    
    @Binding var isShowingTripSettingsSheet: Bool
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition, interactionModes: .all)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(edges: .top)
                .clipShape(.rect(cornerRadius: 16))
            
            TripDetailOverlay(trip: trip, isShowingTripSettingsSheet: $isShowingTripSettingsSheet)
                .transition(
                    .asymmetric(
                        insertion: .opacity.animation(.bouncy),
                        removal: .opacity.animation(.easeOut)
                    )
                )
                .onChange(of: trip.destination.mapCameraPosition, initial: true) {
                    cameraPosition = trip.destination.mapCameraPosition
                }
                .frame(minHeight: 400)
        }
    }
}
//
//#Preview {
//    TripDetailHeader()
//}
