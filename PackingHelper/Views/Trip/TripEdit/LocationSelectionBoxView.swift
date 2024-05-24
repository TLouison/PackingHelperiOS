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
    
    var body: some View {
        ZStack {
            Map(position: $mapCameraPosition)
                .listRowInsets(EdgeInsets())
                .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                
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
                NavigationLink {
                    LocationSelectionView(locationService: LocationService(), location: $location, title: title)
                } label: {
                    EmptyView()
                }.opacity(0)
            }
        }
        .onChange(of: location, initial: true) {
            mapCameraPosition = location.mapCameraPosition
        }
    }
}

#Preview {
    LocationSelectionBoxView(location: .constant(TripLocation.sampleDestination), title: "Example View")
}
