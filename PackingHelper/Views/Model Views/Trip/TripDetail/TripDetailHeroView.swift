//
//  TripDetailHeader.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/18/23.
//

import SwiftUI
import MapKit
import WeatherKit

struct TripDetailHeroView: View {
    @Bindable var trip: Trip
    @Binding var tripWeather: TripWeather?
    
    @Binding var isShowingTripSettingsSheet: Bool
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .clipShape(.rect(cornerRadius: defaultCornerRadius))
            
            TripDetailOverlay(trip: trip, tripWeather: $tripWeather, isShowingTripSettingsSheet: $isShowingTripSettingsSheet)
                .transition(
                    .asymmetric(
                        insertion: .opacity.animation(.bouncy),
                        removal: .opacity.animation(.easeOut)
                    )
                )
                .onChange(of: trip.destination?.mapCameraPosition ?? TripLocation.sampleOrigin.mapCameraPosition,  initial: true) {
                    cameraPosition = trip.destination?.mapCameraPosition ?? TripLocation.sampleOrigin.mapCameraPosition
                }
                .frame(minHeight: 400)
        }
    }
}
//
//#Preview {
//    TripDetailHeader()
//}
