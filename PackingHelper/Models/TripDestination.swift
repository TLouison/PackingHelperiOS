//
//  TripDestination.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import SwiftData
import SwiftUI
import MapKit

@Model
final class TripDestination {
    var name: String
    var latitude: Double
    var longitude: Double
    
    init(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension TripDestination {
    var coordinates: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var mapCameraPosition: MapCameraPosition {
        return MapCameraPosition.region(
            MKCoordinateRegion(
                center:  self.coordinates,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.5,
                    longitudeDelta: 0.5
                )
            )
        )
    }
    
    var mapCameraPositionBinding: Binding<MapCameraPosition> {
        Binding {
            return self.mapCameraPosition
        } set: { newCameraPosition in
            print("Uh")
        }
    }
}

extension TripDestination {
    static var sampleData: TripDestination {
        TripDestination(name: "New York City", latitude: 40.7128, longitude: -74.0060)
    }
}
