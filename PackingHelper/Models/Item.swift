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
}
