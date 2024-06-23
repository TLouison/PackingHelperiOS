//
//  SettingsFormView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import SwiftUI

struct SettingsFormView: View {
    @Bindable var preferences: Preferences
    
    var body: some View {
        Form {
            Picker(
                "Temperature Unit",
                systemImage: "thermometer.sun",
                selection: $preferences.temperatureUnit
            ) {
                ForEach(TemperaturePreference.allCases, id: \.rawValue) { unit in
                    Text("\(unit.rawValue)").tag(unit)
                }
            }
        }
    }
}
