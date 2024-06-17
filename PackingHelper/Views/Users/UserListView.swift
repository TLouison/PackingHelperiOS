//
//  UserListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct UserListView: View {
    @Query private var users: [User]
    
    @State private var isShowingAddUserSheet = false
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(users, id: \.id) { user in
                    Text(user.name)
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
    
    //TODO: Build out deleting logic. Need to handle deleting all lists
    //      associated with the user. Maybe we should offer to leave the
    //      lists in place somehow? Probably not, just tell them and rip
    //      the bandaid off. Also look at UserEditView.swift
}

#Preview {
    UserListView()
}
