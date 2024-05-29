//
//  TripDetailForecastView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/28/24.
//

import SwiftUI
import WeatherKit

struct TripDetailForecastView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Bindable var trip: Trip
    
    @State private var forecast: Forecast<DayWeather>?
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Forecast")
                .font(.title)
                .padding(.bottom, 10)
            
            if let forecast {
                Grid {
                    GridRow {
                        Text("") // Hack because EmptyView does not work in cells
                        Text("")
                        ForEach(forecast, id: \.date) { weather in
                            Text ("\(weather.date.formatted(.dateTime.day()))")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .padding(.bottom, 5)
                        }
                    }
                     
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
                        Text("High").font(.caption)
                        Text("")
                        ForEach(forecast, id: \.date) { weather in
                            Text("\(weather.highTemperature.converted(to: .fahrenheit).formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(.zero)))))")
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
                        Text("Low").font(.caption)
                        Text("")
                        ForEach(forecast, id: \.date) { weather in
                            Text("\(weather.lowTemperature.converted(to: .fahrenheit).formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(.zero)))))")
                                
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            } else {
                Text("Cannot fetch forecast for this trip.")
            }
        }
        .roundedBox()
        .task {
            if ((trip.destination?.canGetWeatherForecast()) != nil) {
                forecast = await trip.destination?.getWeatherForcecast()
            }
        }
    }
}
