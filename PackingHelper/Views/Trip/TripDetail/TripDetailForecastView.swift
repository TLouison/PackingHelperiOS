//
//  TripDetailForecastView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/28/24.
//

import SwiftUI
import WeatherKit

struct TripDetailForecastView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    let trip: Trip
    @Binding var tripWeather: TripWeather?
    @State private var temperatureUnit: UnitTemperature = .fahrenheit
    
    var forecast: Forecast<DayWeather>? {
        if let tripWeather = tripWeather {
            return tripWeather.dailyForecast
        }
        return nil
    }
    
    var body: some View {
        Group {
            if let forecast {
                TripDetailSectionView(title: "Forecast") {
                    Grid {
                        GridRow {
                            Text("\(trip.startDate.formatted(.dateTime.month()))")
                            Text("") // Hack because EmptyView does not work in cells
                            ForEach(forecast, id: \.date) { weather in
                                Text ("\(weather.date.formatted(.dateTime.day()))")
                                    .padding(.bottom, 5)
                            }
                        }
                        .font(.headline)
                        .fontWeight(.semibold)
                        .gridCellAnchor(.top)
                        
                        GridRow {
                            Text("")
                            Text("")
                            
                            ForEach(forecast, id: \.date) { weather in
                                Image(systemName: weather.symbolName)
                                    .font(.title)
                                    .symbolVariant(.fill)
                                    .symbolRenderingMode(colorScheme == .dark ? .multicolor : .palette)
                            }
                        }
                        .padding(.bottom, 10)
                        
                        GridRow {
                            Text("High (\(temperatureUnit.symbol))").font(.caption)
                            Text("")
                            ForEach(forecast, id: \.date) { weather in
                                Text("\(weather.highTemperature.converted(to: temperatureUnit).value.formatted(.number.precision(.fractionLength(.zero))))")
                            }
                        }
                        
                        GridRow {
                            Text("")
                            Text("")
                            ForEach(forecast, id: \.date) { weather in
                                Divider().frame(maxWidth: 30)
                            }
                        }
                        
                        GridRow {
                            Text("Low (\(temperatureUnit.symbol))").font(.caption)
                            Text("")
                            ForEach(forecast, id: \.date) { weather in
                                Text("\(weather.lowTemperature.converted(to: temperatureUnit).value.formatted(.number.precision(.fractionLength(.zero))))")
                                
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                .transition(.move(edge: .bottom))
            }
        }
        .onAppear {
            temperatureUnit = Preferences.getTemperatureUnit(modelContext: modelContext)
        }
    }
}
