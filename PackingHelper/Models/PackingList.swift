//
//  PackingList.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import Foundation
import SwiftData
import OSLog

private let logger = Logger(subsystem: "PackingHelper Models", category: "PackingList")

enum ListType: String, CaseIterable, Comparable {
    case packing="Packing", task="Task"

    private var sortOrder: Int {
        switch self {
            case .packing:
                return 0
            case .task:
                return 1
        }
    }

    var icon: String {
        switch self {
            case .packing: suitcaseIcon
            case .task: "checklist"
        }
    }

    var localizedDisplayName: String {
        switch self {
        case .packing: return "Packing"
        case .task: return "Task"
        }
    }

    static func ==(lhs: ListType, rhs: ListType) -> Bool {
            return lhs.sortOrder == rhs.sortOrder
    }

    static func <(lhs: ListType, rhs: ListType) -> Bool {
       return lhs.sortOrder < rhs.sortOrder
    }
}

// Custom Codable implementation to handle legacy "Day-of" value
extension ListType: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let rawValue = try container.decode(String.self)

        // Handle legacy "Day-of" value by mapping to packing
        if rawValue == "Day-of" {
            self = .packing
        } else if let listType = ListType(rawValue: rawValue) {
            self = listType
        } else {
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: decoder.codingPath,
                    debugDescription: "Cannot initialize ListType from invalid String value \(rawValue)"
                )
            )
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.rawValue)
    }
}

// PackingList sort order
enum PackingListSortOrder: String, SortOrderOption {
    case byDate, byUser, byNameAsc, byNameDesc, byCustomOrder

    var name: String {
        if case .byCustomOrder = self {
            return "Manual Order"
        }
        return BaseSortOrder(rawValue: rawValue)?.name ?? ""
    }

    var id: String { rawValue }

    var `default`: String {
        BaseSortOrder.byDate.name
    }
}

@Model
final class PackingList {
    var created: Date = Date.now

    var type: ListType = ListType.packing
    var typeString: String {
        type.rawValue
    }

    var name: String = "List"

    // Unique identifier for drag-and-drop transfers
    var uuid: UUID = UUID()

    // Default Packing List Variables
    var template: Bool = false
    var countAsDays: Bool = false // Should we set the count of all items to the days of the trip?
    var isDayOf: Bool = false // Is this a Day-of list?
    var appliedFromTemplate: PackingList? = nil // What template list did we create this list from?
    @Relationship(deleteRule:.noAction, inverse: \PackingList.appliedFromTemplate) var appliedToLists: [PackingList]?

    // Sort order for section ordering in sectioned view
    var sortOrder: Int = 0

    var user: User?
    var trip: Trip?

    @Relationship(deleteRule: .cascade, inverse: \Item.list) var items: [Item]?

    init(type: ListType, template: Bool, name: String, countAsDays: Bool, isDayOf: Bool = false, sortOrder: Int = 0) {
        self.created = Date.now
        self.type = type
        self.template = template
        self.items = []
        self.appliedToLists = []
        self.name = name
        self.countAsDays = countAsDays
        self.isDayOf = isDayOf
        self.sortOrder = sortOrder
    }

    var incompleteItems: [Item] {
        self.items?.filter{ $0.isPacked == false } ?? []
    }
    var completeItems: [Item] {
        self.items?.filter{ $0.isPacked == true } ?? []
    }
    var totalItems: Int {
        self.items?.count ?? 0
    }

    func addItem(_ item: Item) {
        if self.items == nil {
            self.items = []
        }
        self.items!.append(item)
    }

    func removeItem(_ item: Item) {
        if self.items != nil {
            print("Removing item \(item.name)")
            self.items!.remove(at: self.items!.firstIndex(of: item)!)
        }
    }

    func removeItem(at index: Int) {
        if self.items != nil {
            print("Removing item at index \(index)")
            self.items?.remove(at: index)
        }
    }

    var icon: String {
        return PackingList.icon(listType: self.type, isDayOf: self.isDayOf)
    }

    static func icon(listType: ListType, isDayOf: Bool = false) -> String {
        if isDayOf {
            return "sun.horizon"
        }
        return switch listType {
            case .packing: suitcaseIcon
            case .task: "checklist"
        }
    }
}

extension PackingList {
    static func save(
        _ packingList: PackingList?,
        name: String,
        type: ListType,
        template: Bool,
        countAsDays: Bool,
        isDayOf: Bool,
        user: User,
        in context: ModelContext,
        for trip: Trip?
    ) {
        logger.info("Saving packing list...")
        if let packingList {
            logger.debug("Packing list already exists. Updating with new info.")
            packingList.name = name
            packingList.type = type
            packingList.user = user
            packingList.countAsDays = countAsDays
            packingList.isDayOf = isDayOf
        } else {
            logger.debug("Packing list does not already exist. Creating with new info.")
            let newPackingList = PackingList(type: type, template: template, name: name, countAsDays: countAsDays, isDayOf: isDayOf)
            newPackingList.user = user

            context.insert(newPackingList)

            if let trip {
                logger.debug("New list belongs to trip, applying to trip's lists.")
                trip.addList(newPackingList)
            }
        }

        do {
            try context.save()
            logger.info("Packing list saved!")
        } catch {
            logger.error("Failed to save packing list: \(error.localizedDescription)")
        }
    }

    static func delete(_ packingList: PackingList, from context: ModelContext) {
        let list_name = packingList.name
        logger.info("Deleting \(list_name)")

        if let trip = packingList.trip {
            logger.info("Removing \(list_name) from trip \(trip.name)")
            _ = trip.removeList(packingList)
        }

        context.delete(packingList)
        do {
            try context.save()
            logger.info("Successfully deleted \(list_name)")
        } catch {
            logger.error("Failed to delete packing list: \(error.localizedDescription)")
        }
    }
}

extension PackingList {
    static func filtered(user: User?, _ lists: [PackingList]) -> [PackingList] {
        if let user {
            return lists.filter{ $0.user == user }
        } else {
            return lists
        }
    }

    static func sorted(_ lists: [PackingList], sortOrder: PackingListSortOrder = .byDate) -> [PackingList] {
        switch sortOrder {
            case .byNameAsc:
                return lists.sorted { $0.name < $1.name }
            case .byNameDesc:
                return lists.sorted { $0.name > $1.name}
            case .byUser:
                return lists.sorted { lhs, rhs in
                    switch (lhs.user, rhs.user) {
                    case (nil, nil): return false
                    case (nil, _): return true
                    case (_, nil): return false
                    case let (l?, r?): return l.name < r.name
                    }
                }
            case .byDate:
                return lists.sorted { $0.created < $1.created }
            case .byCustomOrder:
                return lists.sorted { $0.sortOrder < $1.sortOrder }
            }
    }

    static func containsMultiplePackers(_ lists: [PackingList]) -> Bool {
        return lists.map { $0.user }.count > 1
    }
}

extension PackingList {
    static func samplePackingList() -> PackingList {
        return PackingList(type: .packing, template: false, name: "Packing List", countAsDays: false)
    }


    static func sampleDefaultList() -> PackingList {
        return PackingList(type: .packing, template: true, name: "Template List", countAsDays: false)
    }
}

extension PackingList {
    private static func _copy(_ packingList: PackingList, for trip: Trip? = nil, template: Bool = false) -> PackingList {
        let newList = PackingList(type: packingList.type, template: packingList.template, name: packingList.name, countAsDays: packingList.countAsDays, isDayOf: packingList.isDayOf)
        logger.info("Copied list.")

        if let items = packingList.items {
            logger.info("Original list contained items, copying items to new list.")
            for item in items {
                let newItem: Item
                if template {
                    newItem = Item.copyForTemplate(item)
                } else {
                    newItem = Item.copy(item)
                }
                // Modify the numbers on the list based on number of days if desired
                if !template && packingList.countAsDays {
                    let itemCount = trip?.duration ?? newItem.count
                    logger.info("Original list is marked as 'countAsDays=true', setting item count to \(itemCount)")
                    newItem.count = itemCount
                }

                newList.items?.append(newItem)
            }
        }

        newList.user = packingList.user
        return newList
    }

    static func copy(_ list: PackingList, for trip: Trip) -> PackingList {
        logger.info("Copying packing list \(list.name) to apply to a trip.")
        let newList = PackingList._copy(list, for: trip, template: false)
        newList.template = false

        // Make sure to note what default packing list this was created from
        if list.template {
            newList.appliedFromTemplate = list
        }

        return newList
    }

    static func copy(_ list: PackingList, for trip: Trip, with user: User?) -> PackingList {
        let newList = PackingList.copy(list, for: trip)
        if let user {
            logger.info("Copied packing list \(list.name) to apply to a trip for user \(user.name).")
            newList.user = user
        }
        return newList
    }

    static func copyAsTemplate(_ list: PackingList) -> PackingList {
        let newList = PackingList._copy(list, template: true)
        newList.template = true
        return newList
    }
}
