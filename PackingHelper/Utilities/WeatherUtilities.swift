//
//  WeatherUtilities.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/22/24.
//

import Foundation

//let defaultWeatherFormat: MeasurementFormatter =  .measurement(width: .abbreviated, numberFormatStyle: .number.precision(.fractionLength(.zero)))
func convertCtoF(temperature: Double) -> Double {
    return temperature * (9/5) + 32
}
