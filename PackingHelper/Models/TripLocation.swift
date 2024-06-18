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
import WeatherKit

@Model
final class TripLocation {
    var trip: Trip?
    var name: String = "Location"
    
    var latitude: Double = 40.7128
    var longitude: Double = -74.0060
    
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
    var location: CLLocation {
        CLLocation(latitude: self.latitude, longitude: self.longitude)
    }
    
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
    func canGetCurrentWeather() -> Bool {
        if let trip = self.trip {
            return !trip.complete
        }
        return false
    }
    
    func canGetWeatherForecast() -> Bool {
        if let trip = self.trip {
            return !trip.complete && trip.startDate <= Date().advanced(by: 5 * SECONDS_IN_DAY)
        }
        return false
    }
    
    func getCurrentWeather() async -> CurrentWeather? {
        if self.canGetCurrentWeather() {
            let weatherService = WeatherService()
            
            do {
                return try await weatherService.weather(for: self.location).currentWeather
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func getWeatherForcecast() async -> Forecast<DayWeather>? {
        if canGetWeatherForecast() {
            let weatherService = WeatherService()
            
            if let trip = self.trip {
                // If the trip has begin (i.e. the start date is in the past) we want
                // the start of the forecast to be the current date
                let startDate = max(trip.startDate, Date.now)
                let endDate = startDate.advanced(by: 5 * SECONDS_IN_DAY)
                
                do {
                    return try await weatherService.weather(
                        for: self.location,
                        including: .daily(startDate: startDate, endDate: endDate)
                    )
                } catch {
                    return nil
                }
            }
        }
        return nil
    }
}

extension TripLocation {
    static var sampleOrigin: TripLocation {
        TripLocation(trip: nil, name: "New York City", latitude: 40.7128, longitude: -74.0060)
    }
    
    static var sampleDestination: TripLocation {
        TripLocation(trip: nil, name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
    }
}
