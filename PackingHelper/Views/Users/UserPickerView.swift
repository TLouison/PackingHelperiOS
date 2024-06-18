//
//  UserPickerView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct UserPickerView: View {
    @Query private var users: [User]
    @Binding var selectedUser: User?
    
    var showLabel: Bool = true
    var allowAll: Bool = true
    
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
                ForEach(users, id: \.id) { user in
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
