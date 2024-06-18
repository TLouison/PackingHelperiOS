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
    @State private var isShowingEditUserSheet = false
    @State private var isShowingDeleteConfirmation = false
    
    @State private var selectedUser: User? = nil
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(users, id: \.id) { user in
                    Text(user.name)
                        .swipeActions {
                            Button {
                                isShowingDeleteConfirmation.toggle()
                            } label: {
                                Label("Delete", systemImage: "trash.fill")
                            }
                            .tint(.red)
                            
                            Button {
                                editUser(user)
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .labelStyle(.iconOnly)
                            }
                            .tint(.yellow)
                        }
                        .confirmationDialog(
                            Text("Are you sure you want to delete \(user.name)? This CANNOT be undone, and will delete ALL packing lists that have been created for this user."),
                            isPresented: $isShowingDeleteConfirmation,
                            titleVisibility: .visible
                        ) {
                            Button("Delete", role: .destructive) {
                                withAnimation {
                                    deleteUser(user)
                                }
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
                    .presentationDetents([.height(200)])
            }
            .sheet(isPresented: $isShowingEditUserSheet) {
                UserEditView(user: selectedUser)
                    .presentationDetents([.height(200)])
            }
        }
    }
    
    func editUser(_ user: User) {
        selectedUser = user
        print("Editing user", user)
        isShowingEditUserSheet.toggle()
    }
    
    //TODO: Build out deleting logic. Need to handle deleting all lists
    //      associated with the user. Maybe we should offer to leave the
    //      lists in place somehow? Probably not, just tell them and rip
    //      the bandaid off. Also look at UserEditView.swift
    func deleteUser(_ user: User) {
        print("User", user)
    }
}

#Preview {
    UserListView()
}
