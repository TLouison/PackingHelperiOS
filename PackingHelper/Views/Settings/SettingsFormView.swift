//
//  SettingsFormView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import SwiftUI
import SwiftData

struct SettingsFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    
    @State private var showDeveloperMenu = false
//    @AppStorage("defaultUser") private var defaultUser = -1
    
//    let preferences: Preferences
    
//    @State private var user: User? = nil
    
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
            
            Section("Developer") {
                Button("Open Developer Menu") {
                    showDeveloperMenu = true
                }
            }
            
//            Section("Functionality") {
//                UserPickerView(selectedUser: $user)
//            }
        }
        .sheet(isPresented: $showDeveloperMenu) {
            DeveloperMenuView()
        }
//        .onAppear {
//            self.user = preferences.getSelectedUser(in: modelContext)
//        }
//        .onChange(of: user) {
//            preferences.setSelectedUser(user)
//        }
    }
}
