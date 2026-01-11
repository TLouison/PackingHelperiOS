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

enum ListType: String, Codable, CaseIterable, Comparable {
    case packing="Packing", task="Task", dayOf="Day-of"

    private var sortOrder: Int {
        switch self {
            case .packing:
                return 0
            case .dayOf:
                return 1
            case .task:
                return 2
        }
    }

    var icon: String {
        switch self {
            case .packing: suitcaseIcon
            case .dayOf: "sun.horizon"
            case .task: "checklist"
        }
    }
    
    var localizedDisplayName: String {
        switch self {
        case .packing: return "Packing"
        case .task: return "Task"
        case .dayOf: return "Day-of"
        }
    }

    static func ==(lhs: ListType, rhs: ListType) -> Bool {
            return lhs.sortOrder == rhs.sortOrder
    }

    static func <(lhs: ListType, rhs: ListType) -> Bool {
       return lhs.sortOrder < rhs.sortOrder
    }
}

// PackingList sort order
enum PackingListSortOrder: String, SortOrderOption {
    case byDate, byUser, byNameAsc, byNameDesc
    
    var name: String {
        BaseSortOrder(rawValue: rawValue)?.name ?? ""
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

    // Default Packing List Variables
    var template: Bool = false
    var countAsDays: Bool = false // Should we set the count of all items to the days of the trip?
    var appliedFromTemplate: PackingList? = nil // What default list did we create this list from?
    @Relationship(deleteRule:.noAction, inverse: \PackingList.appliedFromTemplate) var appliedToLists: [PackingList]?

    var user: User?
    var trip: Trip?

    @Relationship(deleteRule: .cascade, inverse: \Item.list) var items: [Item]?

    init(type: ListType, template: Bool, name: String, countAsDays: Bool) {
        self.created = Date.now
        self.type = type
        self.template = template
        self.items = []
        self.appliedToLists = []
        self.name = name
        self.countAsDays = countAsDays
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
        return PackingList.icon(listType: self.type)
    }

    static func icon(listType: ListType) -> String {
        return switch listType {
            case .packing: suitcaseIcon
            case .dayOf: "sun.horizon"
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
        } else {
            logger.debug("Packing list does not already exist. Creating with new info.")
            let newPackingList = PackingList(type: type, template: template, name: name, countAsDays: countAsDays)
            newPackingList.user = user

            context.insert(newPackingList)

            if let trip {
                logger.debug("New list belongs to trip, applying to trip's lists.")
                trip.addList(newPackingList)
            }
        }

        try? context.save()
        logger.info("Packing list saved!")
    }

    static func delete(_ packingList: PackingList, from context: ModelContext) {
        let list_name = packingList.name
        logger.info("Deleting \(list_name)")

        if let trip = packingList.trip {
            logger.info("Removing \(list_name) from trip \(trip.name)")
            _ = trip.removeList(packingList)
        }

        context.delete(packingList)
        try! context.save()
        logger.info("Successfully deleted \(list_name)")
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
                return lists.sorted { $0.user ?? User(name: "aaa") < $1.user ?? User(name: "ZZZ") }
            case .byDate:
                return lists.sorted { $0.created < $1.created }
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
        return PackingList(type: .packing, template: true, name: "Default List", countAsDays: false)
    }
}

extension PackingList {
    private static func _copy(_ packingList: PackingList, for trip: Trip? = nil, template: Bool = false) -> PackingList {
        let newList = PackingList(type: packingList.type, template: packingList.template, name: packingList.name, countAsDays: packingList.countAsDays)
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
