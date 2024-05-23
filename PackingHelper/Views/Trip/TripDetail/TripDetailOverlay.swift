//
//  TripDetailOverlay.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI



struct TripDetailOverlay: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var trip: Trip
    
    @Binding var isShowingTripSettingsSheet: Bool
    
    @State private var showTitle: Bool = false
    @State private var showSubtitle: Bool = false
    
    @ViewBuilder 
    func departureInfo() -> some View {
        let now = Date.now
        let beginDateString = trip.beginDate.formatted(date: .abbreviated, time: .omitted)
        let endDateString = trip.endDate.formatted(date: .abbreviated, time: .omitted)
        
        HStack {
            if now < trip.beginDate {
                trip.type.startLabel(text: "Departing on \(beginDateString)")
            } else if now == trip.beginDate {
                trip.type.startLabel(text: "Departing today!")
            } else if  trip.beginDate < now && now < trip.endDate {
                trip.type.endLabel(text: "Returning on \(endDateString)")
            } else if now == trip.endDate {
                trip.type.endLabel(text: "Trip ended today")
            } else if now > trip.endDate{
                trip.type.endLabel(text: "Returned on \(endDateString)")
            }
        }
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .leading) {
                HStack {
                    Button {
                        dismiss()
                    } label: {
                        Label("Back to Menu", systemImage: "chevron.backward")
                            .labelStyle(.iconOnly)
                            .frame(width: 20, height: 20)
                    }
                    .roundedBox()
                    .shadow(radius: defaultShadowRadius)
                    
                    
                    Spacer()
                    
                    Button {
                        isShowingTripSettingsSheet.toggle()
                    } label: {
                        Label("Trip Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                            .frame(width: 20, height: 20)
                    }
                    .roundedBox()
                }
                .padding()
                
                Spacer()
                
                if showTitle {
                    VStack {
                        Text(trip.name).font(.largeTitle)
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                withAnimation {
                                    showSubtitle = true
                                }
                            }
                        
                        if showSubtitle {
                            departureInfo()
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                        }
                    }
                    .transition(.opacity)
                    .roundedBox()
                }
            }
        }
        .onAppear {
            withAnimation(.easeIn(duration: 0.5)) {
                showTitle = true
            }
        }
    }
}
