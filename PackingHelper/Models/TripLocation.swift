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
    var name: String = "Location"
    
    @Relationship(inverse: \Trip.origin) var originTrips: [Trip]? = []
    @Relationship(inverse: \Trip.destination) var destinationTrips: [Trip]? = []
    
    var latitude: Double = 40.7128
    var longitude: Double = -74.0060
    
    var created: Date = Date.now
    
    @Transient var weather: TripWeather = TripWeather(currentWeather: nil, dailyForecast: nil)
    var weatherLastFetched: Date = Date.distantPast
    
    init(name: String, latitude: Double, longitude: Double) {
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
    func canGetCurrentWeather(for trip: Trip) -> Bool {
        return !trip.complete
    }
    
    func canGetWeatherForecast(for trip: Trip) -> Bool {
        return !trip.complete && trip.startDate <= Date().advanced(by: 5 * SECONDS_IN_DAY)
    }
    
    func getCurrentWeather(for trip: Trip) async -> CurrentWeather? {
        if self.canGetCurrentWeather(for: trip) {
            let weatherService = WeatherService()
            
            do {
                return try await weatherService.weather(for: self.location).currentWeather
            } catch {
                return nil
            }
        }
        return nil
    }
    
    private func getForecastStartAndEnd(trip: Trip) -> (start: Date, end: Date) {
        // If the trip has begin (i.e. the start date is in the past) we want
        // the start of the forecast to be the current date
        let startDate = max(trip.startDate, Date.now)
        let endDate = startDate.advanced(by: 5 * SECONDS_IN_DAY)
        return (startDate, endDate)
    }
    
    func getWeatherForecast(for trip: Trip) async -> Forecast<DayWeather>? {
        if canGetWeatherForecast(for: trip) {
            let weatherService = WeatherService()
            
            let (startDate, endDate) = self.getForecastStartAndEnd(trip: trip)
            
            do {
                return try await weatherService.weather(
                    for: self.location,
                    including: .daily(startDate: startDate, endDate: endDate)
                )
            } catch {
                return nil
            }
        }
        return nil
    }
    
    func getTripWeather(for trip: Trip) async -> TripWeather? {
        // Try to get cached weather first. We refetch every hour, or if the app has been fully closed.
        print("Trying to return cached weather. Last fetched: \(self.weatherLastFetched), \(self.weatherLastFetched.distance(to: .now))")
        if weatherLastFetched.distance(to: .now) < SECONDS_IN_MINUTE * MINUTES_IN_HOUR {
            return self.weather
        }
        
        self.weatherLastFetched = Date.now
        let weatherService = WeatherService()
        
        let allowCurrentWeather = canGetCurrentWeather(for: trip)
        let allowForecastWeather = canGetWeatherForecast(for: trip)
        
        if allowCurrentWeather && allowForecastWeather {
            print("Trying to get both weathers")
            let (startDate, endDate) = self.getForecastStartAndEnd(trip: trip)
            
            do {
                let weatherData = try await weatherService.weather(
                    for: self.location,
                    including: .daily(startDate: startDate, endDate: endDate),
                    .current
                )
                self.weather = TripWeather(currentWeather: weatherData.1, dailyForecast: weatherData.0)
            } catch {
                print("Failed to fetch weather")
                return nil
            }
        } else if allowCurrentWeather {
            print("Getting only current weather")
            self.weather = await TripWeather(currentWeather: self.getCurrentWeather(for: trip), dailyForecast: nil)
        } else if allowForecastWeather {
            print("Getting only forecast weather")
            self.weather = await TripWeather(currentWeather: nil, dailyForecast: self.getWeatherForecast(for: trip))
        } else {
            print("Getting no weather")
            self.weather = TripWeather(currentWeather: nil, dailyForecast: nil)
        }
        return self.weather
    }
}

extension TripLocation {
    static var sampleOrigin: TripLocation {
        TripLocation(name: "New York City", latitude: 40.7128, longitude: -74.0060)
    }
    
    static var sampleDestination: TripLocation {
        TripLocation(name: "Amsterdam", latitude: 52.3676, longitude: 4.9041)
    }
}
