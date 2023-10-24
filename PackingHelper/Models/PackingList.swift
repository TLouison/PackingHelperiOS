//
//  PackingList.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/13/23.
//

import Foundation
import SwiftData

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
        self.items.filter{ $0.isPacked == false && $0.type == .regular }
    }
    var packedItems: [Item] {
        self.items.filter{ $0.isPacked == true && $0.type == .regular}
    }
    var dayOfItems: [Item] {
        self.items.filter{ $0.type == .dayOf }
    }
    
    func deleteItem(_ item: Item) {
        if self.items.contains(item) {
            self.items.remove(at: self.items.firstIndex(of: item)!)
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

