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
    var created: Date = Date.now
    
    @Relationship(deleteRule: .cascade, inverse: \PackingList.user) var lists: [PackingList]?
    
    var colorHex: String = Color.teal.toHex()!
    
    init(name: String) {
        self.name = name
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
