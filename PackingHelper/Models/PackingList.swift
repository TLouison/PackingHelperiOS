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
        if var items = self.items {
            items.remove(at: items.firstIndex(of: item)!)
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
    static func copy(_ packingList: PackingList) -> PackingList {
        let newList = PackingList(type: packingList.type, template: packingList.template, name: packingList.name)
        newList.items = packingList.items
        newList.user = packingList.user
        return newList
    }
    
    static func copyForTrip(_ list: PackingList) -> PackingList {
        let newList = PackingList.copy(list)
        newList.template = false
        return newList
    }
}
