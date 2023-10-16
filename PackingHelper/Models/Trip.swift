//
//  Trip.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Trip {
    enum TripStatus {
        case upcoming, departing, active, returning, complete
    }
    
    var name: String
    var complete: Bool
    
    @Relationship(deleteRule: .cascade) var destination: TripDestination?
    @Relationship(deleteRule: .cascade) var packingList: PackingList
    
    var createdDate: Date
    var beginDate: Date
    var endDate: Date
    
    init(name: String, complete: Bool, beginDate: Date, endDate: Date) {
        self.name = name
        self.complete = complete
        
        self.createdDate = Date.now
        self.beginDate = beginDate
        self.endDate = endDate
        
        self.packingList = PackingList()
    }
}

extension Trip {
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
    static var sampleTrip = Trip(name: "Paraguay", complete: false, beginDate: Date.now, endDate: Date.now.addingTimeInterval(86400))
}

extension Trip {
    static let endIcon = "airplane.arrival"
    static let startIcon = "airplane.departure"
}
