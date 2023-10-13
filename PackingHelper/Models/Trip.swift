//
//  Trip.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import Foundation
import SwiftData
import MapKit
import _MapKit_SwiftUI

@Model
final class Trip {
    var name: String
    var complete: Bool
    
    var destinationLatitude: Double
    var destinationLongitude: Double
    
    var beginDate: Date
    var endDate: Date
    
    init(name: String, complete: Bool, beginDate: Date, endDate: Date, latitude: Double, longitude: Double) {
        self.name = name
        self.complete = complete
        
        self.beginDate = beginDate
        self.endDate = endDate
        
        self.destinationLatitude = latitude
        self.destinationLongitude = longitude
    }
}

extension Trip {
    var destinationCoordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: self.destinationLatitude, longitude: self.destinationLongitude)
    }
    
    var destinationMapCameraPosition: MapCameraPosition {
        return MapCameraPosition.region(
            MKCoordinateRegion(
                center:  self.destinationCoordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: 0.5,
                    longitudeDelta: 0.5
                )
            )
        )
    }
}

extension Trip {
    static var sampleTrip = Trip(name: "Paraguay", complete: false, beginDate: Date.now, endDate: Date.now.addingTimeInterval(86400), latitude: 40.7128, longitude: -74.0060)
}
