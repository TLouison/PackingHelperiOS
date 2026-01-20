//
//  SettingsFormView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import SwiftUI
import SwiftData

import RevenueCat
import RevenueCatUI

enum PackerType: String, CaseIterable {
    case nightBefore = "Night Before"
    case morningOf = "Morning Of"
}

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) var colorScheme
    
    @AppStorage("isDarkMode") private var isDarkMode = true
    @AppStorage("packerType") private var packerType = PackerType.nightBefore.rawValue
    @AppStorage("defaultLocation") private var defaultLocationData: Data = try! JSONEncoder().encode(TripLocation.sampleOrigin)
    @AppStorage("notificationTime") private var notificationMinutes = 480
    
    @State private var selectedTime = Date()
    @State private var showDeveloperMenu = false
    @State private var currentLocation: TripLocation = TripLocation.sampleOrigin
    @State private var displayPaywall: Bool = false
    
    private var defaultLocation: Binding<TripLocation> {
        Binding(
            get: {
                if let location = try? JSONDecoder().decode(TripLocation.self, from: defaultLocationData) {
                    return location
                }
                return TripLocation.sampleDestination
            },
            set: { newLocation in
                if let encoded = try? JSONEncoder().encode(newLocation) {
                    defaultLocationData = encoded
                }
            }
        )
    }
    
    func setDarkMode() {
        isDarkMode = colorScheme == .dark
    }
    
    var body: some View {
        NavigationStack {
            Form {
                if FeatureFlags.showingSubscription {
                    Section("Premium") {
                        //                    NavigationLink {
                        //                        PackingHelperPlusStoreView()
                        //                    } label: {
                        //                        Label {
                        //                            Text("Upgrade to Premium")
                        //                        } icon: {
                        //                            Image(systemName: "plus.square.fill")
                        //                                .foregroundStyle(defaultLinearGradient)
                        //                        }
                        //                    }
                        Button {
                            displayPaywall.toggle()
                        } label: {
                            Label {
                                Text("Upgrade to Premium")
                            } icon: {
                                Image(systemName: "plus.square.fill")
                                    .foregroundStyle(defaultLinearGradient)
                            }
                        }
                    }
                }
                
                Section("Appearance") {
                    Toggle(isOn: $isDarkMode) {
                        Label("Dark Mode", systemImage: "moon.fill")
                    }
                }
                
                Section(header: Text("Packing Preference")) {
                    Picker("When do you pack?", selection: $packerType) {
                        ForEach(PackerType.allCases, id: \.self) { type in
                            Text(type.rawValue).tag(type.rawValue)
                        }
                    }
                }
                
                // TODO: Come back and fix this default location implementation
                //       It currently doesn't actually update the user default
                //                Section("Default Location") {
                //                    LocationSelectionBoxView(location: defaultLocation, title: "Default Location")
                //                        .onChange(of: defaultLocation.wrappedValue) { newLocation in
                //                            print(newLocation.name)
                //                        }
                //                }
                
                Section(header: Text("Notification Time")) {
                    DatePicker(
                        "Notification Time",
                        selection: Binding(
                            get: {
                                Calendar.current.date(from: DateComponents(hour: notificationMinutes / 60, minute: notificationMinutes % 60)) ?? Date()
                            },
                            set: { newValue in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                notificationMinutes = (components.hour ?? 0) * 60 + (components.minute ?? 0)
                            }
                        ),
                        displayedComponents: .hourAndMinute
                    )
                }
                
                Section("Developer") {
                    Button("Open Developer Menu") {
                        showDeveloperMenu = true
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .sheet(isPresented: $showDeveloperMenu) {
                DeveloperMenuView()
            }
            .sheet(isPresented: $displayPaywall) {
                PaywallView()
            }
            .navigationTitle("Settings")
            .onAppear {
                // Update currentLocation with the stored value when the view appears
                let decodedLocation = DefaultLocationInformation.decode(from: defaultLocationData) ?? .default
                currentLocation = TripLocation(
                    name: decodedLocation.name,
                    latitude: decodedLocation.latitude,
                    longitude: decodedLocation.longitude
                )
            }
        }
    }
}

// Extension to help with accessing settings throughout the app
extension UserDefaults {
    var packerType: PackerType {
        PackerType(rawValue: string(forKey: "packerType") ?? PackerType.nightBefore.rawValue) ?? .nightBefore
    }
    
    var defaultLocation: String {
        string(forKey: "defaultLocation") ?? ""
    }
    
    var notificationTime: Date {
        let minutes = integer(forKey: "notificationTime")
        return Calendar.current.date(from: DateComponents(hour: minutes / 60, minute: minutes % 60)) ?? Date()
    }
}


