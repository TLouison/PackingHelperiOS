//
//  WeatherUtilities.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/22/24.
//

import Foundation
import WeatherKit

struct TripWeather {
    let currentWeather: CurrentWeather?
    let dailyForecast: Forecast<DayWeather>?
    
    func getCurrentTemperature(in unit: UnitTemperature = .celsius) -> Measurement<UnitTemperature>? {
        if let currentWeather {
            return currentWeather.temperature
                .converted(to: unit)
        }
        return nil
    }
    
    func getCurrentTemperatureString() -> String? {
        if let currentTemperature = self.getCurrentTemperature() {
            return getCurrentWeatherFormattedTemperature(currentTemperature: currentTemperature)
        }
        return nil
    }
}

func getCurrentWeatherFormattedTemperature(currentTemperature: Measurement<UnitTemperature>) -> String {
    return currentTemperature.formatted(.measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(.zero))))
}
