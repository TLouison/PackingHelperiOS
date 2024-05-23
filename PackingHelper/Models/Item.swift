//
//  Item.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/22/23.
//

import SwiftData

@Model
class Item {
    var name: String
    var count: Int
    var category: String
    var isPacked: Bool
    
    init(name: String, category: String, count: Int, isPacked: Bool) {
        self.name = name
        self.count = count
        self.category = category
        self.isPacked = isPacked
    }
    
    static func copy(_ item: Item) -> Item {
        return Item(name: item.name, category: item.category, count: item.count, isPacked: item.isPacked)
    }
}
