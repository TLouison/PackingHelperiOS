//
//  User.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/3/24.
//

import SwiftUI
import SwiftData

@Model
final class User: Comparable {
    static func < (lhs: User, rhs: User) -> Bool {
        lhs.name < rhs.name
    }
    
    var name: String = "Packer"
    var created: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \PackingList.user) var lists: [PackingList]?
    
    var colorHex: String = Color.teal.toHex()!
    
    init(name: String) {
        self.name = name
    }
    
    static func create_or_update(_ user: User?, name: String, color: Color, in context: ModelContext) {
        if let user {
            user.name = name
            user.setUserColor(color)
        } else {
            let newUser = User(name: name)
            newUser.setUserColor(color)
            context.insert(newUser)
        }
    }
}

// All non-init CRUD functions go here
extension User {
    // Attempts to delete the user, but may fail for various reasons. Returns true
    // if the delete was successful, false otherwise.
    static func delete(_ user: User, from context: ModelContext) -> Bool {
        // Try and delete all related packing lists first, then delete the user
        if let userLists = user.lists {
            for packingList in userLists {
                print("Deleting packing list for deleted user \(user.name) for trip \(packingList.trip?.name ?? "Unknown Name")")
                context.delete(packingList)
            }
        }
        print("Deleting user", user.name)
        context.delete(user)
        return true
    }
}

extension User {
    static var sampleUser: User {
        return User(name: "Todd")
    }
}

extension User {
    func setUserColor(_ color: Color) {
        self.colorHex = color.toHex() ?? Color.accentColor.toHex()!
    }
    
    var userColor: Color {
        return Color(hex: self.colorHex) ?? Color.accentColor
    }
}

extension User {
    var pillIcon: some View {
        return Text(self.name)
            .font(.caption2.smallCaps())
            .fontWeight(.semibold)
            .shadow(
                color: Color.gray.opacity(0.3), /// shadow color
                radius: 3, /// shadow radius
                x: 0, /// x offset
                y: 2 /// y offset
            )
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(self.userColor.opacity(0.5))
            .clipShape(.capsule)
            .shaded()
    }
}
