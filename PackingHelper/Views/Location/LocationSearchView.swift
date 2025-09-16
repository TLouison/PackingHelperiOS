//
//  LocationSearchView.swift
//  PackingHelper
//
//  Created by Todd Louison on 9/15/25.
//


import SwiftUI
import MapKit

struct LocationSearchView: View {
    @Binding var location: TripLocation?
    @Environment(\.dismiss) var dismiss
    
    @State private var searchText = ""
    @State private var searchResults: [Place] = []
    @State private var isSearching = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search for location...", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                    
                    if isSearching {
                        ProgressView()
                            .scaleEffect(0.8)
                    }
                    
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Results List
                List(searchResults) { place in
                    Button(action: {
                        selectPlace(place)
                    }) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(place.name)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(place.address)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(PlainListStyle())
            }
            .navigationTitle("Search Location")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                }
            )
        }
        .task(id: searchText) {
            await performSearch()
        }
    }
    
    private func selectPlace(_ place: Place) {
        guard let coordinate = place.mapItem.placemark.location?.coordinate else { return }
        
        location = TripLocation(
            name: place.name,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        
        dismiss()
    }
    
    private func performSearch() async {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        defer { isSearching = false }
        
        do {
            // Debounce
            try await Task.sleep(nanoseconds: 500_000_000)
            
            let request = MKLocalSearch.Request()
            request.naturalLanguageQuery = searchText
            request.resultTypes = [.address, .pointOfInterest]
            
            let search = MKLocalSearch(request: request)
            let response = try await search.start()
            
            searchResults = response.mapItems.map { Place(mapItem: $0) }
        } catch {
            if !Task.isCancelled {
                searchResults = []
            }
        }
    }
}

// Place model remains the same
struct Place: Identifiable {
    let id = UUID()
    let mapItem: MKMapItem
    
    var name: String {
        mapItem.name ?? "Unknown"
    }
    
    var address: String {
        let placemark = mapItem.placemark
        var addressComponents: [String] = []
        
        if let city = placemark.locality {
            addressComponents.append(city)
        }
        if let state = placemark.administrativeArea {
            addressComponents.append(state)
        }
        if let country = placemark.country {
            addressComponents.append(country)
        }
        
        return addressComponents.joined(separator: ", ")
    }
}
