//
//  TripDetailOverlay.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import WeatherKit

struct TripDetailOverlay: View {
    @Environment(\.dismiss) var dismiss
    @Bindable var trip: Trip
    
    @Binding var isShowingTripSettingsSheet: Bool
    
    @State private var showTitle: Bool = false
    @State private var showSubtitle: Bool = false
    
    @State private var currentWeather: CurrentWeather? = nil
    
    @ViewBuilder 
    func departureInfo() -> some View {
        let now = Date.now
        let beginDateString = trip.startDate.formatted(date: .abbreviated, time: .omitted)
        let endDateString = trip.endDate.formatted(date: .abbreviated, time: .omitted)
        
        HStack {
            if now < trip.startDate {
                Label { Text("Departing on \(beginDateString)") } icon: { trip.type.startIcon }
            } else if now == trip.startDate {
                Label { Text("Departing today!") } icon: { trip.type.startIcon }
            } else if  trip.startDate < now && now < trip.endDate {
                Label { Text("Returning on \(endDateString)") } icon: { trip.type.endIcon }
            } else if now == trip.endDate {
                Label { Text("Trip ended today") } icon: { trip.type.endIcon }
            } else if now > trip.endDate{
                Label { Text("Returned on \(endDateString)") } icon: { trip.type.endIcon }
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
                        
                        if (currentWeather != nil) {
                            Label(currentWeather!.temperature.formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(.zero)))), systemImage: currentWeather!.symbolName)
                        }
                        
                        if showSubtitle {
                            departureInfo()
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                        }
                    }
                    .transition(.opacity)
                    .roundedBox()
                    .task {
                        currentWeather = await trip.destination?.getCurrentWeather()
                    }
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
