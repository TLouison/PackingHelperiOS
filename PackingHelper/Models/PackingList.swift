//
//  PackingList.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import Foundation
import SwiftData

enum ListType: String, Codable, CaseIterable, Comparable {
    case packing="Packing", dayOf="Day-of", task="Task"
    
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

@Model
final class PackingList {
    var created: Date = Date.now
    
    var type: ListType = ListType.packing
    var template: Bool = false
    var name: String = "List"
    
    var user: User?
    var trip: Trip?
    @Transient var tripID: PersistentIdentifier? = nil
    
    @Relationship(deleteRule: .cascade, inverse: \Item.list) var items: [Item]?
    
    init(type: ListType, template: Bool, name: String) {
        self.created = Date.now
        self.type = type
        self.template = template
        self.items = []
        self.name = name
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
    private static func copy(_ packingList: PackingList, template: Bool = false) -> PackingList {
        let newList = PackingList(type: packingList.type, template: packingList.template, name: packingList.name)

        if let items = packingList.items {
            for item in items {
                if template {
                    newList.items?.append(Item.copyForTemplate(item))
                } else {
                    newList.items?.append(Item.copy(item))
                }
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
