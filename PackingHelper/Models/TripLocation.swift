//
//  TripLocation.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import Observation
import SwiftData
import SwiftUI
import MapKit

@Model
final class TripLocation {
    var trip: Trip?
    var name: String
    
    var latitude: Double
    var longitude: Double
    
    init(trip: Trip?, name: String, latitude: Double, longitude: Double) {
        self.trip = trip
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func update(name: String, latitude: Double, longitude: Double) {
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
    }
    
    func update(_ destination: TripLocation) {
        self.name = destination.name
        self.latitude = destination.latitude
        self.longitude = destination.longitude
    }
}

extension TripLocation {
    var coordinates: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: self.latitude, longitude: self.longitude)
    }
    
    var mapCameraPosition: MapCameraPosition {
        MapCameraPosition.region(
            MKCoordinateRegion(
                center:  self.coordinates,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.5,
                    longitudeDelta: 0.5
                )
            )
        )
    }
}

extension TripLocation {
    static var sampleData: TripLocation {
        TripLocation(trip: nil, name: "New York City", latitude: 40.7128, longitude: -74.0060)
    }
}
