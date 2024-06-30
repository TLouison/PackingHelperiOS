//
//  LocationSelectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/12/23.
//

import SwiftUI
import MapKit

struct LocationSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @ObservedObject var locationService: LocationService
    
    @Binding var location: TripLocation
    
    var title: String
    
    var body: some View {
        Form {
            Section {
                ZStack(alignment: .trailing) {
                    TextField("Search", text: $locationService.queryFragment)
                    // This is optional and simply displays an icon during an active search
                    if locationService.status == .isSearching {
                        Image(systemName: "magnifyingglass.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .symbolEffect(.pulse, options: .repeating)
                            .imageScale(.large)
                    }
                }
            } header: {
                Text("Location Search")
            }
            
            Section {
                List {
                    switch locationService.status {
                    case .noResults: AnyView(Text("No Results"))
                    case .error(let description):  AnyView(Text("Error: \(description)"))
                    default: AnyView(EmptyView())
                    }
                    
                    ForEach(locationService.searchResults, id: \.self) { completionResult in
                        Button(completionResult.title) {
                            Task {
                                await getCoordsFromAddress(completionResult.title)
                            }
                        }
                    }
                }
            } header: {
                Text("Results")
            }
        }
        .navigationTitle(title)
        .toolbarTitleDisplayMode(.inline)
        .presentationDetents([.large])
    }
    
    func getCoordsFromAddress(_ address: String) async {
        do {
            let result = try await CLGeocoder().geocodeAddressString(address)
            location.latitude = (result[0].location?.coordinate.latitude)!
            location.longitude = (result[0].location?.coordinate.longitude)!
            location.name = result[0].name ?? "Unknown"
            
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//#Preview {
//    LocationSelectionView()
//}
