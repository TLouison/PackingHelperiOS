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
            .presentationDetents([.height(500), .large])
            .presentationDragIndicator(.automatic)
    }
}

struct TripDetailView: View {
    let trip: Trip
    
    @State private var isShowingTripDetailSheet: Bool = false
    @State private var isShowingTripSettingsSheet: Bool = false
    
    @GestureState private var isDetectingLongPress = false
    @State private var completedLongPress = false
    @State private var isShowingTapAnywherePrompt = false
    
    
    var longPress: some Gesture {
        LongPressGesture(maximumDistance: 100)
            .updating($isDetectingLongPress) { currentState, gestureState,
                transaction in
                gestureState = currentState
            }
            .onEnded { finished in
                self.completedLongPress = finished
                if self.completedLongPress {
                    withAnimation {
                        isShowingTapAnywherePrompt = true
                    }
                }
            }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                TripDetailHero(
                    trip: trip,
                    isShowingTripSettingsSheet: $isShowingTripSettingsSheet
                )
                    .shadow(radius: 4)
                
                TripPackingSheet(packingList: trip.packingList)
                    .shadow(radius: 4)
            }
            .padding()
            .sheet(isPresented: $isShowingTripDetailSheet) {
                TripDetailSheet(trip: trip)
                    .modifier(SheetModifier())
            }
            .sheet(isPresented: $isShowingTripSettingsSheet) {
                TripEditView(trip: trip)
                    .modifier(SheetModifier())
            }
            .toolbar(.hidden, for: .navigationBar)
            .gesture(longPress)
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
