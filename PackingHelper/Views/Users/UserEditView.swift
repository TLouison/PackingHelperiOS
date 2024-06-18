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
}

//#Preview {
//    UserEditView()
//}
