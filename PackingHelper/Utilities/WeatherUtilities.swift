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
}
