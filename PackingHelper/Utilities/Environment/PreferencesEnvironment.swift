//
//  PreferencesEnvironment.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import Foundation

public extension EnvironmentValues {
    var preferences: Preferences {
        get { self[PreferencesKey.self] }
        set { self[PreferencesKey.self] = newValue }
    }
}
