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
    case plane, car, boat, train
    
    var name: String {
        switch self {
        case .plane: "Plane"
        case .car: "Car"
        case .boat: "Boat"
        case .train: "Train"
        }
    }
    
    @ViewBuilder
    func startLabel(text: String) -> some View {
        // Car icon is wrong way around
        if self == .car {
            Label {
                Text(text)
            } icon: {
                Image(systemName: self.startIcon).scaleEffect(CGSize(width: -1.0, height: 1.0))
            }
        } else {
            Label(text, systemImage: self.startIcon)
        }
    }
    
    @ViewBuilder
    func endLabel(text: String) -> some View {
        // Car icon is wrong way around
        if self == .train || self == .boat {
            Label {
                Text(text)
            } icon: {
                Image(systemName: self.startIcon).scaleEffect(CGSize(width: -1.0, height: 1.0))
            }
        } else {
            Label(text, systemImage: self.startIcon)
        }
    }
    
    var startIcon: String {
        switch self {
            case .plane:
                return "airplane.departure"
            case .train:
                return "train.side.front.car"
            case .car:
                return "car.side"
            case .boat:
                return "sailboat"
        }
    }
    
    var endIcon: String {
        switch self {
            case .plane:
                return "airplane.arrival"
            case .train:
                return "train.side.front.car"
            case .car:
                return "car.side"
            case .boat:
                return "sailboat"
        }
    }
}

@Model
final class Trip {
    enum TripStatus {
        case upcoming, departing, active, returning, complete
    }
    
    var name: String
    
    @Relationship(deleteRule: .cascade, inverse: \TripLocation.trip) var destination: TripLocation?
    @Relationship(deleteRule: .cascade, inverse: \PackingList.trip) var lists = [PackingList]()
    
    var beginDate: Date
    var endDate: Date
    var createdDate: Date
    
    var type: TripType = TripType.plane
    
    var dayOfNotificationUUID: String?
    
    init(name: String, beginDate: Date, endDate: Date, type: TripType, destination: TripLocation) {
        self.createdDate = Date.now
        
        self.name = name
        
        self.beginDate = beginDate
        self.endDate = endDate
        
        self.type = type
        
        self.destination = destination
        
        self.createDayOfPackingNotification()
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
        return Calendar.current.numberOfDaysBetween(self.beginDate, and: self.endDate)
    }
    
    var daysUntilDeparture: Int {
        if self.status == .upcoming {
            return Calendar.current.numberOfDaysBetween(.now, and: self.beginDate)
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
    static var sampleTrip = Trip(name: "Paraguay", beginDate: Date.now, endDate: Date.now.addingTimeInterval(86400), type: .plane ,destination: TripLocation.sampleData)
}


// Trip display code
extension Trip {
    
    static let startIcon = "airplane.departure"
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
        var components = Calendar.current.dateComponents([.day, .month, .year], from: self.beginDate)
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
