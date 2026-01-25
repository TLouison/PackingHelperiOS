//
//  LocationSelectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/12/23.
//

import SwiftUI
import OSLog

struct LocationSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var locationService: LocationService
    @Binding var location: TripLocation
    
    var title: String
    
    var body: some View {
        Form {
            Section {
                HStack {
                    TextField("Search", text: $locationService.queryFragment)
                    Button(action: {
                        locationService.performSearch()
                    }) {
                        Text("Search")
                    }
                    .buttonStyle(.bordered)
                }
                
                if locationService.status == .isSearching {
                    HStack {
                        Spacer()
                        ProgressView()
                            .padding(.vertical, 8)
                        Spacer()
                    }
                }
            } header: {
                Text("Location Search")
            }
            
            Section {
                switch locationService.status {
                case .noResults:
                    Text("No Results")
                case .error(let description):
                    Text("Error: \(description)")
                        .foregroundColor(.red)
                case .result:
                    ForEach(locationService.searchResults) { result in
                        Button(result.formattedName) {
                            selectLocation(result)
                        }
                    }
                case .idle, .isSearching:
                    EmptyView()
                }
            } header: {
                Text("Results")
            }
        }
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inline)
        .presentationDetents([.large])
        .submitLabel(.search)
        .onSubmit {
            locationService.performSearch()
        }
    }
    
    private func selectLocation(_ result: LocationService.LocationResult) {
        if let latitude = Double(result.lat),
           let longitude = Double(result.lon) {
            location.latitude = latitude
            location.longitude = longitude
            location.name = result.abbreviatedName
            AppLogger.location.debug("Selected location: \(result.abbreviatedName)")
            dismiss()
        }
    }
}
