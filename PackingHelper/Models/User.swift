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
    var created: Date = Date()
    
    @Relationship(deleteRule: .cascade, inverse: \PackingList.user) var lists: [PackingList]?
    
    init(name: String) {
        self.name = name
    }
}

extension User {
    var pillIcon: some View {
        return Text(self.name)
            .font(.caption)
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(.ultraThickMaterial)
            .clipShape(.capsule)
    }
}
