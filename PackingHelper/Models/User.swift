//
//  User.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/3/24.
//

import SwiftData

@Model
final class User {
    var name: String
    
    init(name: String, primary: Bool) {
        self.name = name
    }
}
