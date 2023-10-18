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
    var items: [Item]
    var created: Date
    
    init() {
        self.items = []
        self.created = Date.now
    }
}

@Model
class Item {
    var name: String
    var count: Int
    var packed: Bool
    
    init(name: String, count: Int) {
        self.name = name
        self.count = count
        self.packed = false
    }
}
