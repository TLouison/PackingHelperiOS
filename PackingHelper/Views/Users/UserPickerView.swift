//
//  UserPickerView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct UserPickerView: View {
    @Query(sort: \User.created, order: .forward) private var users: [User]
    @Binding var selectedUser: User?
    
    var tripForFiltering: Trip? = nil
    
    var showLabel: Bool = true
    var allowAll: Bool = true
    
    var filteredUsers: [User] {
        if let tripForFiltering {
            return users.filter({ user in
                tripForFiltering.lists?.contains(where: { list in
                    list.user == user
                }) ?? false
            })
        } else {
            return users
        }
    }
    
    var body: some View {
        HStack {
            if showLabel {
                Label("Showing Lists For", systemImage: "person.circle")
                Spacer()
            }
            Picker("User", selection: $selectedUser) {
                if allowAll {
                    Text("Show All").tag(nil as User?)
                }
                ForEach(filteredUsers, id: \.id) { user in
                    if showLabel {
                        Text(user.name).tag(user as User?)
                    } else {
                        Label(user.name, systemImage: "person.circle").tag(user as User?)
                    }
                }
            }
            .background(.thickMaterial)
            .rounded()
        }
    }
}

//#Preview {
//    UserPickerView()
//}
