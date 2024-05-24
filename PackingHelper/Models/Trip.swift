//
//  Trip.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import Foundation
import SwiftData
import SwiftUI

enum TripType: Codable, CaseIterable {
    case plane, car, train, boat, ferry
    
    var name: String {
        switch self {
        case .plane: "Plane"
        case .car: "Car"
        case .boat: "Boat"
        case .train: "Train"
        case .ferry: "Ferry"
        }
    }
    
    @ViewBuilder
    func startLabel(text: String) -> some View {
        Label(
            title: { Text(text) },
            icon: { self.endIcon }
        )
    }
    
    @ViewBuilder
    func endLabel(text: String) -> some View {
        Label(
            title: { Text(text) },
            icon: { self.endIcon }
        )
    }
    
    var startIcon: Image {
        switch self {
            case .plane:
                return Image(systemName: "airplane.departure")
            case .train:
                return Image(systemName: "train.side.front.car")
            case .car:
                return Image(systemName: "car")
            case .ferry:
                return Image(systemName: "car.ferry")
            case .boat:
                return Image(systemName: "ferry")
        }
    }
    
    var endIcon: Image {
        switch self {
            case .plane:
                return Image(systemName: "airplane.arrival")
            case .train:
                return Image(systemName: "train.side.front.car")
            case .car:
                return Image(systemName: "car")
            case .ferry:
                return Image(systemName: "car.ferry")
            case .boat:
                return Image(systemName: "ferry")
        }
    }
}

@Model
final class Trip {
    enum TripStatus {
        case upcoming, departing, active, returning, complete
    }
    
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \TripLocation.trip) var origin: TripLocation?
    @Relationship(deleteRule: .cascade, inverse: \TripLocation.trip) var destination: TripLocation?
    @Relationship(deleteRule: .cascade, inverse: \PackingList.trip) var lists = [PackingList]()
    
    var startDate: Date
    var endDate: Date
    var createdDate: Date
    
    var type: TripType = TripType.plane
    
    var dayOfNotificationUUID: String?
    
    init(name: String, startDate: Date, endDate: Date, type: TripType, origin: TripLocation, destination: TripLocation) {
        self.createdDate = Date.now
        
        self.name = name
        
        self.startDate = startDate
        self.endDate = endDate
        
        self.type = type
        
        self.origin = origin
        self.destination = destination
        
        self.createDayOfPackingNotification()
    }
}

extension Trip {
    var complete: Bool {
        return Date.now >= self.endDate
    }
    
    var status: TripStatus {
        if Date.now < self.startDate {
            return .upcoming
        } else if Date.now == self.startDate {
            return .departing
        } else if Date.now == self.endDate {
            return .returning
        } else if Date.now > self.endDate {
            return .complete
        } else {
            return .active
        }
    }
    
    @ViewBuilder
    func getStatusLabel() -> some View {
        switch self.status {
        case .upcoming, .departing:
            self.type.startLabel(text: "Upcoming")
        case .returning, .complete:
            self.type.endLabel(text: "Complete")
        default:
            self.type.startLabel(text: "In Progess")
        }
    }
}

// List-related Trip Code
extension Trip {
    // Gets amount of Items stored in related lists regardless of type
    var totalListEntries: Int {
        return self.lists.reduce(0, {x,y in
            x + y.items.count
        })
    }
    
    var totalIncompletePackingItemsEntries: Int {
        return self.lists.filter{$0.type != .task}.reduce(0, {x,y in
            x + y.incompleteItems.count
        })
    }
    
    func getTotalItems(for listType: ListType) -> Int {
        return self.lists.filter {$0.type == listType}.reduce(0, {x, y in
            x + y.items.count
        })
    }
    
    func getIncompleteItems(for listType: ListType) -> Int {
        return self.lists.filter {$0.type == listType}.reduce(0, {x, y in
            x + y.incompleteItems.count
        })
    }
    
    func getCompleteItems(for listType: ListType) -> Int {
        return self.lists.filter {$0.type == listType}.reduce(0, {x, y in
            x + y.completeItems.count
        })
    }
    
    func allItemsComplete(for listType: ListType) -> Bool {
        return self.getTotalItems(for: listType) == self.getCompleteItems(for: listType)
    }
}

extension Trip {
    /// Duration of trip in number of days
    var duration: Int {
        return Calendar.current.numberOfDaysBetween(self.startDate, and: self.endDate)
    }
    
    var daysUntilDeparture: Int {
        if self.status == .upcoming {
            return Calendar.current.numberOfDaysBetween(.now, and: self.startDate)
        } else {
            return 0
        }
    }
    
    var daysUntilReturn: Int {
        if self.status == .active {
            return Calendar.current.numberOfDaysBetween(.now, and: self.endDate)
        } else {
            return 0
        }
    }
}

extension Trip {
    static var sampleTrip = Trip(name: "Paraguay", startDate: Date(), endDate: Date.now.addingTimeInterval(86400), type: .plane, origin: TripLocation.sampleOrigin, destination: TripLocation.sampleDestination)
}

/// Notification Code
extension Trip {
    func createDayOfPackingNotification() {
        NotificationUtilities.getNotificationPermission()
        
        // Create the content
        let content = UNMutableNotificationContent()
        content.title = "Check your packing lists!"
        content.body = "You have \(self.totalIncompletePackingItemsEntries) items to pack before you head out."
        
        // Configure the date
        var components = Calendar.current.dateComponents([.day, .month, .year], from: self.startDate)
        components.hour = 8
        
        // Create the trigger as a one-time event.
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        // Create the request
        self.dayOfNotificationUUID = UUID().uuidString
        let request = UNNotificationRequest(identifier: self.dayOfNotificationUUID!,
                                            content: content, trigger: trigger)
        
        
        // Schedule the request with the system.
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
}
