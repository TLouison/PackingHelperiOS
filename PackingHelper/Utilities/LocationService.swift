//
//  LocationService.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/12/23.
//

import Foundation

class LocationService: ObservableObject {
    enum LocationStatus: Equatable {
        case idle
        case noResults
        case isSearching
        case error(String)
        case result
    }
    
    struct LocationAddress: Codable {
        let city: String
        let county: String
        let state: String
        let country: String
        let country_code: String
    }
    
    struct LocationResult: Codable, Identifiable {
        let id = UUID()
        let display_name: String
        let lat: String
        let lon: String
        let address: Address
        let importance: Double
        
        struct Address: Codable {
            let city: String?
            let town: String?
            let village: String?
            let hamlet: String?
            let state: String?
            let country: String?
        }
        
        var formattedName: String {
            // Get the city name from the most specific field available
            let cityName = address.city ?? address.town ?? address.village ?? address.hamlet ?? ""
            
            if address.country == "United States" {
                return "\(cityName), \(address.state ?? ""), United States"
            } else {
                return "\(cityName), \(address.country ?? "")"
            }
        }
        
        var abbreviatedName: String {
                // Get the city name from the most specific field available
                let cityName = address.city ?? address.town ?? address.village ?? address.hamlet ?? ""
                
                if address.country == "United States" {
                    return "\(cityName), \(address.state ?? "")"
                } else {
                    // For non-US locations, return the full name if it's just city, country
                    return "\(cityName), \(address.country ?? "")"
                }
            }
    }

    
    @Published var queryFragment: String = ""
    @Published private(set) var status: LocationStatus = .idle
    @Published private(set) var searchResults: [LocationResult] = []
    
    func performSearch() {
        guard !queryFragment.isEmpty else {
            status = .idle
            searchResults = []
            return
        }
        
        status = .isSearching
        searchLocation(queryFragment)
    }
    
    private func searchLocation(_ query: String) {
        var components = URLComponents(string: "https://nominatim.openstreetmap.org/search")
        components?.queryItems = [
            URLQueryItem(name: "q", value: query),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "featureclass", value: "P"),
            URLQueryItem(name: "type", value: "city"),
            URLQueryItem(name: "limit", value: "10"),
            URLQueryItem(name: "addressdetails", value: "1")  // Required for detailed address information
        ]
        
        guard let url = components?.url else {
            self.status = .error("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("PackingHelper/1.0 (toddmlouison@gmail.com)", forHTTPHeaderField: "User-Agent")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 15
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.status = .error("Network error: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    switch httpResponse.statusCode {
                    case 200: break // Success
                    case 429:
                        self.status = .error("Rate limited. Please try again in a moment.")
                        return
                    case 403:
                        self.status = .error("Access denied. Please check app permissions.")
                        return
                    default:
                        self.status = .error("Server error: \(httpResponse.statusCode)")
                        return
                    }
                }
                
                guard let data = data else {
                    self.status = .error("No data received")
                    return
                }
                
                do {                    
                    let results = try JSONDecoder().decode([LocationResult].self, from: data)
                    
                    // Filter out invalid or unwanted results
                    let filteredResults = results.filter { result in
                        // Ensure we have at least a city/town/village name and a country
                        guard let placeName = result.address.city ?? result.address.town ??
                                            result.address.village ?? result.address.hamlet,
                              let country = result.address.country else {
                            return false
                        }
                        
                        // Filter out any results where the place name contains numbers
                        guard !placeName.contains(where: { $0.isNumber }) else {
                            return false
                        }
                        
                        // Filter out results containing unwanted terms
                        let unwantedTerms = ["County", "Parish", "Borough", "Municipality",
                                           "District", "Metropolitan", "Region", "Prefecture"]
                        let hasUnwantedTerm = unwantedTerms.contains { term in
                            placeName.contains(term)
                        }
                        
                        return !hasUnwantedTerm
                    }
                    
                    // Sort by importance score and deduplicate while preserving order
                    var seen = Set<String>()
                    let uniqueResults = filteredResults
                        .sorted { $0.importance > $1.importance }
                        .filter { result in
                            seen.insert(result.formattedName).inserted
                        }
                    
                    self.searchResults = uniqueResults
                    self.status = uniqueResults.isEmpty ? .noResults : .result
                    
                } catch {
                    self.status = .error("Decoding error: \(error.localizedDescription)")
                }
            }
        }.resume()
    }
}

struct DefaultLocationInformation: Codable {
    let name: String
    let latitude: Double
    let longitude: Double
}

// Extension to handle the encoding/decoding
extension DefaultLocationInformation {
    // Helper function to encode to Data
    func encode() -> Data? {
        try? JSONEncoder().encode(self)
    }
    
    // Static helper function to decode from Data
    static func decode(from data: Data) -> DefaultLocationInformation? {
        try? JSONDecoder().decode(DefaultLocationInformation.self, from: data)
    }
    
    // Provide a default value
    static var `default`: DefaultLocationInformation {
        DefaultLocationInformation(name: "New York, New York", latitude: 40.7128, longitude: -74.006)
    }
}
