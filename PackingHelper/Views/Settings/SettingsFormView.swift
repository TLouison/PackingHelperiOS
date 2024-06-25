//
//  SettingsFormView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import SwiftUI

struct SettingsFormView: View {
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("isDarkMode") private var isDarkMode = false
    
    @Bindable var preferences: Preferences
    
    func setDarkMode() {
        isDarkMode = colorScheme == .dark
    }
    
    var body: some View {
        Form {
            Section("Appearance") {
                Toggle(isOn: $isDarkMode) {
                    Label("Dark Mode", systemImage: "moon.fill")
                }
            }
        }
    }
}
