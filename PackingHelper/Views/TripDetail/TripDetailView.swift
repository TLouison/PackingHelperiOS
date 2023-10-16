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
    @State var trip: Trip
    
    @State private var isShowingTripDetailSheet: Bool = false
    @State private var isShowingTripSettingsSheet: Bool = false
    @State private var isShowingPackingDetailSheet: Bool = false
    
    @State private var cameraPosition: MapCameraPosition = .automatic
    
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
        Map(position: $cameraPosition, interactionModes: .all)
            .background(Color.black)
            .overlay {
                if completedLongPress {
                    VStack {
                        Spacer()
                        if isShowingTapAnywherePrompt {
                            Text("Tap here to show details again.")
                                .font(.callout)
                                .padding()
                                .background(.ultraThinMaterial)
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .ignoresSafeArea()
                                .transition(
                                    .asymmetric(
                                        insertion: .scale.animation(.bouncy),
                                        removal: .scale.animation(.easeOut)
                                    )
                                )
                                .onTapGesture {
                                    withAnimation {
                                        completedLongPress = false
                                        isShowingTapAnywherePrompt = false
                                    }
                                }
                        }
                    }
                } else {
                    TripDetailOverlay(
                        trip: $trip,
                        isShowingTripDetailSheet: $isShowingTripDetailSheet,
                        isShowingPackingDetailSheet: $isShowingPackingDetailSheet,
                        isShowingTripSettingsSheet: $isShowingTripSettingsSheet
                    )
                    .transition(
                        .asymmetric(
                            insertion: .opacity.animation(.bouncy),
                            removal: .opacity.animation(.easeOut)
                        )
                    )
                    .animation(.easeInOut, value: isDetectingLongPress)
                }
            }
            .sheet(isPresented: $isShowingTripDetailSheet) {
                TripDetailSheet(trip: trip)
                    .modifier(SheetModifier())
            }
            .sheet(isPresented: $isShowingTripSettingsSheet) {
                TripEditView(trip: trip)
            }
            .sheet(isPresented: $isShowingPackingDetailSheet) {
                TripPackingSheet(packingList: $trip.packingList)
                    .modifier(SheetModifier())
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                cameraPosition = MapCameraPosition.region(
                    MKCoordinateRegion(
                        center:  trip.destination?.coordinates ?? TripDestination.sampleData.coordinates,
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.5,
                            longitudeDelta: 0.5
                        )
                    )
                )
            }
            .gesture(longPress)
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
