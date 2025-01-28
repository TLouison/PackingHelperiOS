//
//  LocationSelectionBoxView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/23/24.
//

import SwiftUI
import MapKit

struct LocationSelectionBoxView: View {
    @Binding var location: TripLocation
    
    @State private var mapCameraPosition: MapCameraPosition = TripLocation.sampleDestination.mapCameraPosition
    
    var title: String
    
    init(location: Binding<TripLocation>, title: String) {
        self._location = location
        self._mapCameraPosition = State(initialValue: location.wrappedValue.mapCameraPosition)
        self.title = title
    }
    
    var body: some View {
        ZStack {
            Map(position: $mapCameraPosition)
                .listRowInsets(EdgeInsets())
                .frame(height: 80)
                .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                .allowsHitTesting(false)
            
            HStack {
                Text(location.name).bold().font(.headline)
                Spacer()
                Image(systemName: "magnifyingglass.circle")
                    .foregroundStyle(.blue.gradient)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
            .padding(.horizontal)
            .overlay {
                            let locationBinding = Binding<TripLocation>(
                                get: { location },
                                set: { newValue in
                                    var binding = self._location
                                    location = newValue
                                    binding.update()
                                }
                            )
                            
                            NavigationLink {
                                LocationSelectionView(
                                    locationService: LocationService(),
                                    location: locationBinding,
                                    title: title
                                )
                            } label: {
                                EmptyView()
                            }.opacity(0)
                        }
            
        }
        .onChange(of: location, initial: true) { _, newLocation in
            mapCameraPosition = newLocation.mapCameraPosition
        }
    }
}

#Preview {
    LocationSelectionBoxView(location: .constant(TripLocation.sampleDestination), title: "Example View")
}
