//
//  TripDetailHeader.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/18/23.
//

import SwiftUI
import MapKit

struct TripDetailHeroView: View {
    @Bindable var trip: Trip
    
    @Binding var isShowingTripSettingsSheet: Bool
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(.rect(cornerRadius: defaultCornerRadius))
            
            TripDetailOverlay(trip: trip, isShowingTripSettingsSheet: $isShowingTripSettingsSheet)
                .transition(
                    .asymmetric(
                        insertion: .opacity.animation(.bouncy),
                        removal: .opacity.animation(.easeOut)
                    )
                )
                .onChange(of: trip.destination?.mapCameraPosition ?? TripDestination.sampleData.mapCameraPosition,  initial: true) {
                    cameraPosition = trip.destination?.mapCameraPosition ?? TripDestination.sampleData.mapCameraPosition
                }
                .frame(minHeight: 400)
        }
        
    }
}
//
//#Preview {
//    TripDetailHeader()
//}
