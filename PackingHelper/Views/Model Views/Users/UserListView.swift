//
//  UserListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct UserListView: View {
    @Query(sort: \User.created, order: .forward, animation: .smooth) private var users: [User]
    
    @State private var isShowingAddUserSheet = false

    var body: some View {
        NavigationStack {
            Group {
                if users.isEmpty {
                    MissingUsersView()
                } else {
                    List {
                        ForEach(users, id: \.id) { user in
                            UserListRowView(user: user)
                        }
                    }
                }
            }
            .navigationTitle("Packers")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        withAnimation {
                            isShowingAddUserSheet.toggle()
                        }
                    } label: {
                        Label("Add Packer", systemImage: "plus.circle")
                            .labelStyle(.iconOnly)
                            .symbolEffect(.bounce.down, value: isShowingAddUserSheet)
                    }
                }
            }
            .sheet(isPresented: $isShowingAddUserSheet) {
                UserEditView(user: nil)
                    .presentationDetents([.height(400)])
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    UserListView()
}
