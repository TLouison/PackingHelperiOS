//
//  UserListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct UserListView: View {
    @Query(animation: .smooth) private var users: [User]
    
    @State private var isShowingAddUserSheet = false

    var body: some View {
        NavigationStack {
            List {
                ForEach(users, id: \.id) { user in
                    UserListRowView(user: user)
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
                    .presentationDetents([.height(200)])
            }
        }
    }
}

#Preview {
    UserListView()
}
