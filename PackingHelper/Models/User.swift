//
//  User.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/3/24.
//

import SwiftUI
import SwiftData

@Model
final class User {
    var name: String = "Packer"
    
    @Relationship(deleteRule: .cascade, inverse: \PackingList.user) var lists: [PackingList]?
    
    init(name: String) {
        self.name = name
    }
}
