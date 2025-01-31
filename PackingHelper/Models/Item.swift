//
//  Item.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/22/23.
//

import Foundation
import SwiftData

@Model
class Item {
    var name: String = "Item"
    var list: PackingList?
    var count: Int = 1
    var category: String = "Clothing"
    var isPacked: Bool = false
    
    var created: Date = Date.now
    
    init(name: String, category: String, count: Int, isPacked: Bool) {
        self.name = name
        self.count = count
        self.category = category
        self.isPacked = isPacked
    }
    
    static func copy(_ item: Item) -> Item {
        let copyItem = Item(name: item.name, category: item.category, count: item.count, isPacked: item.isPacked)
        copyItem.list = item.list
        return copyItem
    }
    
    static func copyForTemplate(_ item: Item) -> Item {
        let copyItem = Item(name: item.name, category: item.category, count: item.count, isPacked: false)
        copyItem.list = item.list
        return copyItem
    }
    
    static func create(for list: PackingList, in context: ModelContext, category: PackingRecommendationCategory?, name: String, count: Int, isPacked: Bool) {
        var itemCategory = category
        if list.type == .task {
            itemCategory = .Task
        } else {
            if itemCategory == nil {
                itemCategory = PackingEngine.interpretItem(itemName: name)
            }
        }
        
        let newItem = Item(
            name: name,
            category: itemCategory!.rawValue.capitalized,
            count: count,
            isPacked: isPacked
        )
        newItem.list = list
        
        list.addItem(newItem)
        context.insert(newItem)
    }
    
    static func sorted(_ items: [Item], sortOrder: ItemSortOrder = .byDate) -> [Item] {
        switch sortOrder {
            case .byNameAsc:
                return items.sorted { $0.name < $1.name }
            case .byNameDesc:
                return items.sorted { $0.name > $1.name}
            case .byUser:
                return items.sorted { $0.list?.user ?? User(name: "aaa") < $1.list?.user ?? User(name: "ZZZ") }
            case .byList:
                return items.sorted { $0.list?.name ?? "aaa" < $1.list?.name ?? "ZZZ" }
            case .byDate:
                return items.sorted { $0.created < $1.created }
            }
    }
}

// Item sort order with additional case
enum ItemSortOrder: String, SortOrderOption {
    case byDate, byUser, byNameAsc, byNameDesc, byList
    
    var name: String {
        if case .byList = self {
            return "By List (A-Z)"
        }
        return BaseSortOrder(rawValue: rawValue)?.name ?? ""
    }
    
    var id: String { rawValue }
    
    var `default`: String {
        BaseSortOrder.byDate.rawValue
    }
}
