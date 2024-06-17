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
    
    var body: some View {
        HStack {
            Label("Showing Lists For", systemImage: "person.circle")
            Spacer()
            Picker("User", selection: $selectedUser) {
                Text("Show All").tag(nil as User?)
                ForEach(users, id: \.id) { user in
                    Text(user.name).tag(user as User?)
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
