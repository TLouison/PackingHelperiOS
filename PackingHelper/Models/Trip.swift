//
//  Trip.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/9/23.
//

import Foundation
import SwiftData
import SwiftUI
import OSLog

private let logger = Logger(subsystem: "PackingHelper Models", category: "Trip")

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

enum TripAccomodation: Codable, CaseIterable {
    case hotel, rental, family, friend

    var name: String {
        switch self {
        case .family: "Family"
        case .friend: "Friend"
        case .hotel: "Hotel"
        case .rental: "Rental"
        }
    }
}

@Model
final class Trip {
    enum TripStatus {
        case upcoming, departing, active, returning, complete
    }

    var uuid: UUID = UUID()
    var name: String = "Trip"

    @Relationship(deleteRule: .cascade, inverse: \TripLocation.trip) var origin: TripLocation?
    @Relationship(deleteRule: .cascade, inverse: \TripLocation.trip) var destination: TripLocation?
    @Relationship(deleteRule: .cascade, inverse: \PackingList.trip) var lists: [PackingList]? = []

    var startDate: Date = Date.now
    var endDate: Date = Date.now.advanced(by: SECONDS_IN_DAY)
    var createdDate: Date = Date.now

    var type: TripType = TripType.plane
    var accomodation: TripAccomodation = TripAccomodation.hotel

    var dayOfNotificationUUID: String?

    static let maxFreeTrips: Int = 3

    init(name: String, startDate: Date, endDate: Date, type: TripType, origin: TripLocation, destination: TripLocation, accomodation: TripAccomodation) {
        self.createdDate = Date.now

        self.name = name

        self.startDate = startDate
        self.endDate = endDate

        self.type = type
        self.accomodation = accomodation

        self.origin = origin
        self.destination = destination

        self.createDayOfPackingNotification()
    }

    static func create_or_update(
        _ trip: Trip?,
        name: String,
        startDate: Date,
        endDate: Date,
        tripType: TripType,
        origin: TripLocation,
        destination: TripLocation,
        accomodation: TripAccomodation,
        in context: ModelContext
    ) -> Trip {
        if let trip {
            trip.name = name

            trip.startDate = startDate
            trip.endDate = endDate

            trip.type = tripType
            trip.accomodation = accomodation

            trip.origin = origin
            trip.destination = destination
            return trip
        } else {
            let newTrip = Trip(
                name: name,
                startDate: startDate,
                endDate: endDate,
                type: tripType,
                origin: origin,
                destination: destination,
                accomodation: accomodation
            )
            context.insert(newTrip)
            return newTrip
        }
    }

    static func delete(_ trip: Trip, in context: ModelContext) {
        context.delete(trip)
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
            Text("Upcoming")
        case .returning, .complete:
            Text("Complete")
        default:
            Text("In Progress")
        }
    }

    @ViewBuilder
    func getTypeLabel() -> some View {
        switch self.status {
        case .upcoming, .departing:
            self.type.startLabel(text: "\(self.type.name)")
        case .returning, .complete:
            self.type.endLabel(text: "\(self.type.name)")
        default:
            self.type.startLabel(text: "\(self.type.name)")
        }
    }
}

// List-related Trip Code
extension Trip {
    // MARK: List metadata
    var hasMultiplePackers: Bool {
        return self.lists?.compactMap( { $0.user } ).count ?? 0 > 1
    }

    var containsListTypes: [ListType] {
        return Set(self.lists?.compactMap( { $0.type } ) ?? []).sorted()
    }

    var listsFromTemplates: [PackingList] {
        return self.lists?.filter { $0.appliedFromTemplate != nil } ?? []
    }

    var alreadyUsedTemplates: [PackingList] {
        // We already filtered out all appliedFromTemplate == nil, so force unwrap is safe
        return self.listsFromTemplates.map { $0.appliedFromTemplate! }
    }

    // MARK: List counts
    // Gets amount of Items stored in related lists regardless of type
    var totalListEntries: Int {
        return self.lists?.reduce(0, {x,y in
            x + (y.items?.count ?? 0)
        }) ?? 0
    }

    var totalIncompletePackingItemsEntries: Int {
        return self.lists?.filter{$0.type != .task}.reduce(0, {x,y in
            x + y.incompleteItems.count
        }) ?? 0
    }

    func getTotalItems(for listType: ListType) -> Int {
        return self.lists?.filter {$0.type == listType}.reduce(0, {x, y in
            x + (y.items?.count ?? 0)
        }) ?? 0
    }

    func getIncompleteItems(for listType: ListType) -> Int {
        return self.lists?.filter {$0.type == listType}.reduce(0, {x, y in
            x + y.incompleteItems.count
        }) ?? 0
    }

    func getCompleteItems(for listType: ListType) -> Int {
        return self.lists?.filter {$0.type == listType}.reduce(0, {x, y in
            x + y.completeItems.count
        }) ?? 0
    }

    func allItemsComplete(for listType: ListType) -> Bool {
        return self.getTotalItems(for: listType) == self.getCompleteItems(for: listType)
    }

    // MARK: Get Lists
    func getLists(for listType: ListType) -> [PackingList] {
        return self.lists?.filter {$0.type == listType} ?? []
    }

    func getLists(for user: User?) -> [PackingList] {
        if let user {
            return self.lists?.filter {$0.user == user} ?? []
        } else {
            return self.lists ?? []
        }
    }

    func getLists(for user: User?, ofType listType: ListType) -> [PackingList] {
        if let user {
            return self.getLists(for: user).filter {$0.type == listType }
        } else {
            return self.getLists(for: listType)
        }
    }

    // MARK: CRUD Lists
    func addList(_ list: PackingList) {
        if self.lists == nil {
            self.lists = []
        }
        self.lists!.append(list)
    }

    func removeList(_ listToRemove: PackingList) -> Bool {
        // Make sure to remove the list from the model context as well if fully deleting!
        if var lists = self.lists {
            logger.debug("Removing \(listToRemove.name) from lists of \(self.name)")
            lists.remove(at: (lists.firstIndex(of: listToRemove))!)
            return true
        }
        return false
    }

    func applyDefaultLists(to user: User?, lists: [PackingList]) {
        if !lists.isEmpty {
            for list in lists {
                let defaultList = PackingList.copy(list, for: self, with: user)
                defaultList.tripID = self.id
                self.addList(defaultList)
            }
        }
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
    static var sampleTrip = Trip(name: "Anniversary Trip", startDate: Date(), endDate: Date.now.addingTimeInterval(86400), type: .plane, origin: TripLocation.sampleOrigin, destination: TripLocation.sampleDestination, accomodation: .hotel)
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
