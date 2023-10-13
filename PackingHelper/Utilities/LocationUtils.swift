//
//  LocationUtils.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/12/23.
//

import Foundation
import MapKit

struct AddressResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
}

struct AnnotationItem: Identifiable {
    let id = UUID()
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
