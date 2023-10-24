//
//  Item.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/22/23.
//

import SwiftData

enum PackingListType: String, Codable {
    case regular = "Regular"
    case dayOf = "Day-of"
}


@Model
class Item {
    var name: String
    var count: Int
    var type: PackingListType
    var isPacked: Bool
    
    init(name: String, count: Int, isPacked: Bool, type: PackingListType) {
        self.name = name
        self.count = count
        self.isPacked = isPacked
        self.type = type
    }
    
    static func copy(_ item: Item) -> Item {
        return Item(name: item.name, count: item.count, isPacked: item.isPacked, type:  item.type)
    }
}
