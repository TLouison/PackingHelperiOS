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
    @State private var featureFlags = FeatureFlags.shared
    
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

                    if featureFlags.showingMultiplePackers && showSubtitle{
                        UserIndicators(users: trip.packers)
                            .padding(.horizontal)
                    }

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
                .padding(.top)
                
                Spacer()
                
                if showTitle {
                    if let currentWeather = tripWeather?.currentWeather {
                        WeatherChip(weather: currentWeather)
                    }
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
                        }
                        .font(.subheadline)
                        
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
