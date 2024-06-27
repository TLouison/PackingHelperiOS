//
//  UserListRowView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/17/24.
//

import SwiftUI
import SwiftData

struct UserListRowView: View {
    @Environment(\.modelContext) var modelContext
    
    @Query private var packingLists: [PackingList]
    
    @State private var isShowingEditUserSheet: Bool = false
    @State private var isShowingDeleteConfirmation: Bool = false
    
    let user: User
    
    var body: some View {
        HStack {
            Color(user.userColor)
                .clipShape(.circle)
                .frame(width: 24, height: 24)
                .shaded()
            Text(user.name)
        }
            .swipeActions {
                Button {
                    isShowingDeleteConfirmation.toggle()
                } label: {
                    Label("Delete", systemImage: "trash.fill")
                }
                .tint(.red)
                
                Button {
                    isShowingEditUserSheet.toggle()
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
            .sheet(isPresented: $isShowingEditUserSheet) {
                UserEditView(user: user)
                    .presentationDetents([.height(400)])
            }
    }
    
    func deleteUser(_ user: User) {
        let usersPackingLists = packingLists.filter( { $0.user == user })
        for packingList in usersPackingLists {
            print("Deleting packing list for deleted user \(user.name) for trip \(packingList.trip?.name ?? "Unknown Name")")
            modelContext.delete(packingList)
        }
        print("Deleting user", user.name)
        modelContext.delete(user)
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var users: [User]
    UserListRowView(user: users.first!)
}
