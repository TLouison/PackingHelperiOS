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
            case .packing: "suitcase.rolling.fill"
            case .dayOf: "sun.horizon"
            case .task: "checklist"
        }
    }
    
    static func ==(lhs: ListType, rhs: ListType) -> Bool {
            return lhs.sortOrder == rhs.sortOrder
    }

    static func <(lhs: ListType, rhs: ListType) -> Bool {
       return lhs.sortOrder < rhs.sortOrder
    }
}

enum PackingListSortOrder: String, CaseIterable {
    case byDate, byUser, byNameAsc, byNameDesc 
    
    var name: String {
        switch self {
        case .byDate: "By Created Date"
        case .byNameAsc: "By Name (A-Z)"
        case .byNameDesc: "By Name (Z-A)"
        case .byUser: "By User (A-Z)"
        }
    }
}

@Model
final class PackingList {
    var created: Date = Date.now
    
    var type: ListType = ListType.packing
    var name: String = "List"
    
    // Default Packing List Variables
    var template: Bool = false
    var countAsDays: Bool = false // Should we set the count of all items to the days of the trip?
    
    var user: User?
    var trip: Trip?
    @Transient var tripID: PersistentIdentifier? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Item.list) var items: [Item]?
    
    init(type: ListType, template: Bool, name: String, countAsDays: Bool) {
        self.created = Date.now
        self.type = type
        self.template = template
        self.items = []
        self.name = name
        self.countAsDays = countAsDays
    }
    
    var incompleteItems: [Item] {
        self.items?.filter{ $0.isPacked == false } ?? []
    }
    var completeItems: [Item] {
        self.items?.filter{ $0.isPacked == true } ?? []
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
            case .packing: "suitcase.rolling.fill"
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
        logger.info("Packing list saved!")
    }
    
    static func delete(_ packingList: PackingList, from context: ModelContext) -> Bool {
        let list_name = packingList.name
        logger.info("Deleting \(list_name)")
        
        if let trip = packingList.trip {
            logger.info("Removing \(list_name) from trip \(trip.name)")
            _ = trip.removeList(packingList)
        }
        
        context.delete(packingList)
        logger.info("Successfully deleted \(list_name)")
        return true
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
}

extension PackingList {
    private static func copy(_ packingList: PackingList, template: Bool = false) -> PackingList {
        let newList = PackingList(type: packingList.type, template: packingList.template, name: packingList.name, countAsDays: packingList.countAsDays)

        if let items = packingList.items {
            for item in items {
                let newItem: Item
                if template {
                    newItem = Item.copyForTemplate(item)
                } else {
                    newItem = Item.copy(item)
                }
                // Modify the numbers on the list based on number of days if desired
                if !template && packingList.countAsDays {
                    newItem.count = packingList.trip?.duration ?? newItem.count
                }
                
                newList.items?.append(newItem)
            }
        }
        
        newList.user = packingList.user
        return newList
    }
    
    static func copyForTrip(_ list: PackingList) -> PackingList {
        let newList = PackingList.copy(list)
        newList.template = false
        return newList
    }
    
    static func copyAsTemplate(_ list: PackingList) -> PackingList {
        let newList = PackingList.copy(list, template: true)
        newList.template = true
        return newList
    }
}
