//
//  User.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/3/24.
//

import SwiftData
import SwiftUI

@Model
final class User {
    var name: String
    
    init(name: String) {
        self.name = name
    }
}
