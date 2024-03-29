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
    @Environment(\.dismiss) var dismiss
    
    let trip: Trip
    
    @State private var isShowingTripDetailSheet: Bool = false
    @State private var isShowingTripSettingsSheet: Bool = false
    
    @State private var isAddingNewPackingList: Bool = false
    @State private var isApplyingDefaultPackingList: Bool = false
    
    @GestureState private var isDetectingLongPress = false
    @State private var completedLongPress = false
    @State private var isShowingTapAnywherePrompt = false
    
    var body: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                TripDetailHeroView(
                    trip: trip,
                    isShowingTripSettingsSheet: $isShowingTripSettingsSheet
                )
                    .shadow(radius: defaultShadowRadius)
                
                TripPackingBoxView(
                    trip: trip,
                    isAddingNewPackingList: $isAddingNewPackingList,
                    isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                )
                    .shadow(radius: defaultShadowRadius)
                
                TripDetailInfoView(trip: trip)
                    .shadow(radius: defaultShadowRadius)
            }
            .padding()
            .sheet(isPresented: $isShowingTripDetailSheet) { TripDetailSheet(trip: trip) }
            .sheet(isPresented: $isShowingTripSettingsSheet) { TripEditView(trip: trip) }
            .sheet(isPresented: $isAddingNewPackingList) {
                PackingListEditView(trip: trip, isDeleted: .constant(false))
                    .presentationDetents([.height(225)])
            }
            .sheet(isPresented: $isApplyingDefaultPackingList) {
                PackingListApplyDefaultView(trip: trip)
                    .presentationDetents([.height(175)])
            }
            .toolbar(.hidden, for: .navigationBar)
        }
    }
}
