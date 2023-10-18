//
//  Trip.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import SwiftData
import SwiftUI

@Model
final class Trip {
    enum TripStatus {
        case upcoming, departing, active, returning, complete
    }
    
    var name: String
    
    
    @Relationship(deleteRule: .cascade) var destination: TripDestination
    @Relationship(deleteRule: .cascade) var packingList: PackingList
    
    var createdDate: Date
    var beginDate: Date
    var endDate: Date
    
    init(name: String, beginDate: Date, endDate: Date, destination: TripDestination) {
        self.name = name
        
        self.createdDate = Date.now
        self.beginDate = beginDate
        self.endDate = endDate
        
        self.destination = destination
        self.packingList = PackingList()
    }
}

extension Trip {
    var complete: Bool {
        return Date.now >= self.endDate
    }
    
    var status: TripStatus {
        if Date.now < self.beginDate {
            return .upcoming
        } else if Date.now == self.beginDate {
            return .departing
        } else if Date.now == self.endDate {
            return .returning
        } else if Date.now > self.endDate {
            return .complete
        } else {
            return .active
        }
    }
    
    func getStatusLabel() -> some View {
        switch self.status {
        case .upcoming, .departing:
            return Label("Upcoming", systemImage: "airplane.departure")
        case .returning, .complete:
            return Label("Complete", systemImage: "airplane.arrival")
        default:
            return Label("In Progress", systemImage: "airplane")
        }
    }
}

extension Trip {
    static var sampleTrip = Trip(name: "Paraguay", beginDate: Date.now, endDate: Date.now.addingTimeInterval(86400), destination: TripDestination.sampleData)
}

extension Trip {
    static let endIcon = "airplane.arrival"
    static let startIcon = "airplane.departure"
}
