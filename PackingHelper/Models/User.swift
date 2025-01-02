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
    var profileImageData: Data? // Store image data
    
    @Relationship(deleteRule: .cascade, inverse: \PackingList.user) var lists: [PackingList]?
    
    var colorHex: String = Color.teal.toHex()!
    
    init(name: String, colorHex: String? = nil) {
        self.name = name
        
        if let colorHex {
            self.colorHex = colorHex
        }
    }
    
    static func create_or_update(_ user: User?, name: String, color: Color, profileImage: UIImage? = nil, in context: ModelContext) {
        if let user {
            user.name = name
            user.setUserColor(color)
            if let image = profileImage {
                user.setProfileImage(image)
            }
        } else {
            let newUser = User(name: name)
            newUser.setUserColor(color)
            if let image = profileImage {
                newUser.setProfileImage(image)
            }
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

// Profile Picture methods
extension User {
    func setProfileImage(_ image: UIImage) {
        // Add debug print
        print("Setting profile image")
        if let data = image.jpegData(compressionQuality: 0.7) {
            print("Image data size: \(data.count) bytes")
            self.profileImageData = data
        }
    }
    
    // Add persistence check method
    func verifyImageData() {
        if let data = profileImageData {
            print("Profile image data exists: \(data.count) bytes")
        } else {
            print("No profile image data found")
        }
    }
    
    var profileImage: Image? {
        if let data = profileImageData, let uiImage = UIImage(data: data) {
            return Image(uiImage: uiImage)
        }
        return nil
    }
}

extension User {
    var profileView: some View {
        Group {
            if let profileImage = profileImage {
                profileImage
                    .resizable()
                    .scaledToFill()
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .foregroundStyle(userColor)
            }
        }
        .frame(width: 60, height: 60)
        .clipShape(Circle())
        .shadow(radius: 2)
    }
    
    var pillIcon: some View {
        Text(self.name)
            .font(.caption2.smallCaps())
            .fontWeight(.semibold)
            .shadow(
                color: Color.gray.opacity(0.3),
                radius: 3,
                x: 0,
                y: 2
            )
            .padding(.horizontal)
            .padding(.vertical, 5)
            .background(self.userColor.opacity(0.5))
            .clipShape(.capsule)
            .shaded()
    }
}
