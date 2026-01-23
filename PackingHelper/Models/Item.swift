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

    // Unique identifier for drag-and-drop transfers
    var uuid: UUID = UUID()

    // Sort order within a PackingList (for sectioned view)
    var sortOrder: Int = 0

    // Global sort order across all lists (for unified view)
    var unifiedSortOrder: Int = 0

    init(name: String, category: String, count: Int, isPacked: Bool, sortOrder: Int = 0, unifiedSortOrder: Int = 0) {
        self.name = name
        self.count = count
        self.category = category
        self.isPacked = isPacked
        self.sortOrder = sortOrder
        self.unifiedSortOrder = unifiedSortOrder
    }
    
    static func copy(_ item: Item) -> Item {
        let copyItem = Item(name: item.name, category: item.category, count: item.count, isPacked: item.isPacked, sortOrder: item.sortOrder, unifiedSortOrder: item.unifiedSortOrder)
        copyItem.list = item.list
        return copyItem
    }

    static func copyForTemplate(_ item: Item) -> Item {
        let copyItem = Item(name: item.name, category: item.category, count: item.count, isPacked: false, sortOrder: item.sortOrder, unifiedSortOrder: item.unifiedSortOrder)
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
                return items.sorted { lhs, rhs in
                    switch (lhs.list?.user, rhs.list?.user) {
                    case (nil, nil): return false
                    case (nil, _): return true
                    case (_, nil): return false
                    case let (l?, r?): return l.name < r.name
                    }
                }
            case .byList:
                return items.sorted { $0.list?.name ?? "aaa" < $1.list?.name ?? "ZZZ" }
            case .byDate:
                return items.sorted { $0.created < $1.created }
            case .byCustomOrder:
                return items.sorted { $0.sortOrder < $1.sortOrder }
            case .byUnifiedOrder:
                return items.sorted { $0.unifiedSortOrder < $1.unifiedSortOrder }
            }
    }
}

// Item sort order with additional case
enum ItemSortOrder: String, SortOrderOption {
    case byDate, byUser, byNameAsc, byNameDesc, byList, byCustomOrder, byUnifiedOrder

    var name: String {
        if case .byList = self {
            return "By List (A-Z)"
        }
        if case .byCustomOrder = self {
            return "Manual Order"
        }
        if case .byUnifiedOrder = self {
            return "Unified Order"
        }
        return BaseSortOrder(rawValue: rawValue)?.name ?? ""
    }

    var id: String { rawValue }

    var `default`: String {
        BaseSortOrder.byDate.rawValue
    }
}
