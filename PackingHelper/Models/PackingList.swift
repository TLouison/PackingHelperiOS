//
//  PackingList.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import Foundation
import SwiftData


enum PackingListType: String, Codable {
    case unpacked = "Unpacked"
    case packed = "Packed"
    case dayOf = "Day-of"
}

@Model
final class PackingList {
    var created: Date
    
    var items: [Item]
    
    init() {
        self.items = []
        self.created = Date.now
    }
    
    var unpackedItems: [Item] {
        self.items.filter{ $0.type == .unpacked }
    }
    var packedItems: [Item] {
        self.items.filter{ $0.type == .packed }
    }
    var dayOfItems: [Item] {
        self.items.filter{ $0.type == .dayOf }
    }
    
    func togglePacked(_ item: Item) {
        switch item.type {
        case .unpacked:
            item.type = .packed
        case .packed:
            item.type = .unpacked
        case .dayOf:
            print("UNEXPECTED BEHAVIOR")
        }
    }
}

@Model
class Item {
    var name: String
    var count: Int
    var type: PackingListType
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
        self.type = .unpacked
    }
    
    var isPacked: Bool {
        self.type == .packed
    }
}
