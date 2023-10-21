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
    
    var template: Bool
    var name: String?
    
    init(template: Bool, name: String?) {
        self.created = Date.now
        self.items = []
        self.template = template
        
        if template {
            self.name = name
        }
    }
    
    var nameString: String {
        return self.name ?? "Packing List"
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

extension PackingList {
    static func copy(_ packingList: PackingList) -> PackingList {
        let newList = PackingList(template: packingList.template, name: packingList.name)
        newList.items = packingList.items
        return newList
    }
    
    /// Special case copy function to create a version of the list without the template variables so
    /// it can be used as the packing list for a trip.
    static func copyForTrip(_ packingList: PackingList) -> PackingList {
        let newList = PackingList.copy(packingList)
        newList.template = false
        newList.name = nil
        return newList
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
    
    static func copy(_ item: Item) -> Item {
        var newItem = Item(name: item.name, count: item.count)
        newItem.type = item.type
        return newItem
    }
}
