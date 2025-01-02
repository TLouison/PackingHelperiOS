//
//  UserPickerBaseView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import SwiftData

struct UserPickerBaseView: View {
    @Query(sort: \User.created, order: .forward) private var users: [User]
    @Binding var selectedUser: User?
    
    var tripForFiltering: Trip? = nil
    
    var showIcon: Bool = true
    var allowAll: Bool = true
    
    var filteredUsers: [User] {
        if let tripForFiltering {
            // Filter out users that are not part of this trip. We also
            // need to resort because the filter doesn't guarantee order
            return users.filter({ user in
                tripForFiltering.lists?.contains(where: { list in
                    list.user == user
                }) ?? false
            }).sorted(by: { $0.created < $1.created })
        } else {
            return users
        }
    }
    
    var body: some View {
        Picker("Packer", selection: $selectedUser) {
            if allowAll {
                Text("Show All").tag(nil as User?)
            }
            ForEach(filteredUsers, id: \.id) { user in
                if showIcon {
                    HStack {
                        Image(systemName: "person.circle").frame(width: 16, height: 16).padding(.trailing)
                        Spacer(minLength: 10)
                        Text(user.name)
                    }
                    .tag(user as User?)
                } else {
                    Text(user.name).tag(user as User?)
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            if selectedUser == nil && allowAll == false {
                selectedUser = users.first!
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var users: [User]
    @Previewable @State var selectedUser: User?
    VStack {
        UserPickerBaseView(selectedUser: $selectedUser)
        Divider()
        UserPickerBaseView(selectedUser: $selectedUser, showIcon: true)
        Divider()
        UserPickerBaseView(selectedUser: $selectedUser, allowAll: false)
        Divider()
        UserPickerBaseView(selectedUser: $selectedUser, showIcon: true, allowAll: true)
        Divider()
        UserPickerBaseView(selectedUser: $selectedUser, showIcon: true, allowAll: false)
    }.padding()
}
