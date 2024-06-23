//
//  Preferences.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import Foundation
import SwiftData

enum TemperaturePreference: String, Codable, CaseIterable  {
    case auto="Auto", celsius="Celsius", fahrenheit="Fahrenheit"
}

@Model
final class Preferences {
    var temperatureUnit: TemperaturePreference = TemperaturePreference.auto
    
    init () {
        temperatureUnit = .auto
    }
    
    var currentTemperaturePreference: UnitTemperature {
        switch self.temperatureUnit {
        case .celsius:
            UnitTemperature.celsius
        case .fahrenheit:
            UnitTemperature.fahrenheit
        case .auto:
            UnitTemperature.init(forLocale: .autoupdatingCurrent)
        }
    }
}

extension Preferences {
    public static func getTemperatureUnit(modelContext: ModelContext) -> UnitTemperature {
        let instance = instance(with: modelContext)
        print("Current temperature pref: \(instance.currentTemperaturePreference)")
        return instance.currentTemperaturePreference
   }
}

extension Preferences {
    static func instance(with modelContext: ModelContext) -> Preferences {
        if let result = try! modelContext.fetch(FetchDescriptor<Preferences>()).first {
            return result
        } else {
            let instance = Preferences()
            modelContext.insert(instance)
            return instance
        }
    }
    
    static func ensureExists(with modelContext: ModelContext) {
        _ = instance(with: modelContext)
    }
}
