//
//  UserEditSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/16/24.
//

import SwiftUI
import SwiftData

struct UserEditView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var name = ""
    
    @Query private var users: [User]
    let user: User?
    
    private var editorTitle: String {
        user == nil ? "Add User" : "Edit User"
    }
    
    private var canDelete: Bool {
        !users.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("Name", text: $name)
                }

                if user != nil {
                    VStack {
                        Button(role: .destructive) {
                            deleteUser()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                        .disabled(!canDelete)
                        
                        if !canDelete {
                            Text("You cannot delete this user because there must always be at least one user.").font(.caption)
                        }
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(editorTitle)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        withAnimation {
                            save()
                            dismiss()
                        }
                    }.disabled(!formIsValid)
                }
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let user {
                    // Edit the incoming item.
                    name = user.name
                }
            }
        }
    }
    
    private var formIsValid: Bool {
        return name != ""
    }
    
    private func save() {
        if let user {
            user.name = name
        } else {
            let newUser = User(name: name)
            modelContext.insert(newUser)
        }
    }
    
    //TODO: Build out deleting logic. Need to handle deleting all lists
    //      associated with the user. Maybe we should offer to leave the
    //      lists in place somehow? Probably not, just tell them and rip
    //      the bandaid off.
    private func deleteUser() {
        print("Deleting!")
    }
}

//#Preview {
//    UserEditView()
//}
