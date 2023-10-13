//
//  TripDetailView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import MapKit

struct RoundedModifier: ViewModifier {
    let corner: CGFloat
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: .infinity)
            .padding()
            .clipShape(RoundedRectangle(cornerRadius: corner))
    }
}

struct SheetModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .presentationDetents([.height(200), .medium, .large])
            .presentationDragIndicator(.automatic)
    }
}

struct TripDetailView: View {
    var trip: Trip
    
    @State private var isShowingTripDetailSheet: Bool = false
    @State private var isShowingTripSettingsSheet: Bool = false
    @State private var isShowingPackingDetailSheet: Bool = false
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
    var body: some View {
        Map(position: $cameraPosition, interactionModes: .zoom)
            .opacity(0.7)
            .background(Color.black)
            .overlay {
                TripDetailOverlay(trip: trip, isShowingTripDetailSheet: $isShowingTripDetailSheet, isShowingPackingDetailSheet: $isShowingPackingDetailSheet, isShowingTripSettingsSheet: $isShowingTripSettingsSheet)
            }
            .sheet(isPresented: $isShowingTripDetailSheet) {
                TripDetailSheet(trip: trip)
                    .modifier(SheetModifier())
            }
            .sheet(isPresented: $isShowingTripSettingsSheet) {
                TripEditView(trip: trip)
            }
            .sheet(isPresented: $isShowingPackingDetailSheet) {
                TripPackingSheet(trip: trip)
                    .modifier(SheetModifier())
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                cameraPosition = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center:  trip.destinationCoordinate,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.5,
                            longitudeDelta: 0.5
                        )
                    )
                )
            }
    }
}

//#Preview {
//    MainActor.assumeIsolated {
//        let container = previewContainer.container
//
//        TripDetailView(trip: Trip.sampleTrip)
//            .modelContainer(container)
//    }
//}
