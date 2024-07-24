//
//  TripDetailView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import MapKit
import WeatherKit

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
    @Environment(\.dismiss) private var dismiss
    
    let trip: Trip
    
    @State private var isDeleted: Bool = false
    @State private var isShowingTripDetailSheet: Bool = false
    @State private var isShowingTripSettingsSheet: Bool = false
    
    @State private var isAddingNewPackingList: Bool = false
    @State private var isApplyingDefaultPackingList: Bool = false
    
    @GestureState private var isDetectingLongPress = false
    @State private var completedLongPress = false
    @State private var isShowingTapAnywherePrompt = false
    
    @State private var tripWeather: TripWeather?
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                TripDetailHeroView(
                    trip: trip,
                    tripWeather: $tripWeather,
                    isShowingTripSettingsSheet: $isShowingTripSettingsSheet
                )
                    .shadow(radius: defaultShadowRadius)
                
                TripDetailPackingView(
                    trip: trip,
                    isAddingNewPackingList: $isAddingNewPackingList,
                    isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                )
                    .shadow(radius: defaultShadowRadius)
                
                TripDetailForecastView(trip: trip, tripWeather: $tripWeather)
                    .shadow(radius: defaultShadowRadius)
                
                TripDetailInfoView(trip: trip)
                    .shadow(radius: defaultShadowRadius)
            }
            .padding()
            .sheet(isPresented: $isShowingTripDetailSheet) { TripDetailSheet(trip: trip) }
            .sheet(isPresented: $isShowingTripSettingsSheet) { TripEditView(trip: trip, isDeleted: $isDeleted) }
            .sheet(isPresented: $isAddingNewPackingList) {
                PackingListEditView(trip: trip, isDeleted: .constant(false))
                    .presentationDetents([.height(400), .large])
            }
            .sheet(isPresented: $isApplyingDefaultPackingList) {
                PackingListApplyDefaultView(trip: trip)
            }
            .toolbar(.hidden, for: .navigationBar)
            .onAppear {
                Task {
                    tripWeather = await trip.destination?.getTripWeather()
                }
            }
            .onChange(of: isDeleted) {
                if isDeleted {
                    dismiss()
                }
            }
        }
    }
}
