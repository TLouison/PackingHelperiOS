//
//  TripDetailOverlay.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftUI
import SwiftData
import WeatherKit

struct TripDetailOverlay: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Bindable var trip: Trip
    @Binding var tripWeather: TripWeather?
    
    @Binding var isShowingTripSettingsSheet: Bool
    
    @State private var showTitle: Bool = false
    @State private var showSubtitle: Bool = false
    @State private var temperatureUnit: UnitTemperature = .fahrenheit
    
    var temperature: String {
        if let tripWeather {
            return tripWeather.getCurrentTemperatureString()!
        }
        return "Unknown"
    }
    
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
                    .shaded()
                    
                    
                    Spacer()
                    
                    Button {
                        isShowingTripSettingsSheet.toggle()
                    } label: {
                        Label("Trip Settings", systemImage: "gear")
                            .labelStyle(.iconOnly)
                            .frame(width: 20, height: 20)
                    }
                    .roundedBox()
                    .shaded()
                }
                .padding()
                
                Spacer()
                
                if showSubtitle {
                    UserIndicators(users: trip.packers)
                        .padding(8)
                }
                
                if showTitle {
                    VStack {
                        Text(trip.name).font(.largeTitle)
                            .frame(maxWidth: .infinity)
                            .onAppear {
                                withAnimation {
                                    showSubtitle = true
                                }
                            }
                        
                        HStack {
                            if let destination = trip.destination {
                                Text(destination.name)
                            }
                            
                            if let currentWeather = tripWeather?.currentWeather {
                                HStack {
                                    Divider()
                                        .fixedSize(horizontal: false, vertical: true)
                                    Label(temperature, systemImage: currentWeather.symbolName)
                                }
                                .opacity(tripWeather == nil ? 0 : 1)
                                .animation(.easeIn(duration: 0.5), value: tripWeather != nil)
                            }
                        }
                        .font(.subheadline)
                        .padding(.top, -15)
                        
                        if showSubtitle {
                            departureInfo()
                                .frame(maxWidth: .infinity)
                                .transition(.opacity)
                        }
                    }
                    .transition(.opacity)
                    .roundedBox()
                    .shaded()
                }
            }
            .onAppear {
                withAnimation(.easeIn(duration: 0.5)) {
                    showTitle = true
                }
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    TripDetailOverlay(trip: trips.first!, tripWeather: .constant(nil), isShowingTripSettingsSheet: .constant(false))
}
