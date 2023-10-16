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
    var items: [String]
    var created: Date
    
    init() {
        self.items = []
        self.created = Date.now
    }
}
