//
//  LocationSelectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/12/23.
//

import SwiftUI
import MapKit

struct LocationSelectionView: View {
    @Environment(\.dismiss) var dismiss
    
    @ObservedObject var locationService: LocationService
    
    @Binding var latitude: Double
    @Binding var longitude: Double
    
    var body: some View {
        VStack {
            Form {
                Section(header: Text("Location Search")) {
                    ZStack(alignment: .trailing) {
                        TextField("Search", text: $locationService.queryFragment)
                        // This is optional and simply displays an icon during an active search
                        if locationService.status == .isSearching {
                            Image(systemName: "clock")
                                .foregroundColor(Color.gray)
                        }
                    }
                }
                Section(header: Text("Results")) {
                    List {
                        switch locationService.status {
                            case .noResults: AnyView(Text("No Results"))
                            case .error(let description):  AnyView(Text("Error: \(description)"))
                            default: AnyView(EmptyView())
                        }
                        
                        ForEach(locationService.searchResults, id: \.self) { completionResult in
                            // This simply lists the results, use a button in case you'd like to perform an action
                            // or use a NavigationLink to move to the next view upon selection.
                            Button(completionResult.title) {
                                Task {
                                    await getCoordsFromAddress(completionResult.title)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func getCoordsFromAddress(_ address: String) async {
        do {
            let result = try await CLGeocoder().geocodeAddressString(address)
            latitude = (result[0].location?.coordinate.latitude)!
            longitude = (result[0].location?.coordinate.longitude)!
            dismiss()
        } catch {
            print(error.localizedDescription)
        }
    }
}

//#Preview {
//    LocationSelectionView()
//}
