import SwiftUI
import SwiftData
import PhotosUI

struct UserEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var userColor = Color.accentColor
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var showingDeleteConfirmation = false
    
    
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
                    Section {
                        TextField("Name", text: $name)
                    }
                    
                    Section {
                        VStack {
                            if let selectedImage {
                                Image(uiImage: selectedImage)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else if let profileImage = user?.profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundStyle(userColor)
                            }
                            
                            PhotosPicker(selection: $selectedItem,
                                         matching: .images) {
                                Text("Select Photo")
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical)
                    }
                    
                    Section {
                        UserColorPicker(selectedColor: $userColor)
                    }
                    
                    if let user {
                        Section {
                            Button(role: .destructive) {
                                showingDeleteConfirmation = true
                            } label: {
                                HStack {
                                    Spacer()
                                    Text("Delete User")
                                    Spacer()
                                }
                            }
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
            .alert("Delete User", isPresented: $showingDeleteConfirmation) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let user {
                        deleteUser(user)
                        dismiss()
                    }
                }
            } message: {
                Text("Are you sure you want to delete this user? This will also delete all associated lists and cannot be undone.")
            }
            .onChange(of: selectedItem) { _, newValue in
                Task {
                    if let data = try? await newValue?.loadTransferable(type: Data.self) {
                        if let image = UIImage(data: data) {
                            selectedImage = image
                        }
                    }
                }
            }
            .onAppear {
                if let user {
                    name = user.name
                    userColor = user.userColor
                }
            }
        }
    }
    
    private var formIsValid: Bool {
        return name != ""
    }
    
    private func save() {
        User.create_or_update(user, name: name, color: userColor, profileImage: selectedImage, in: modelContext)
        
        // Force save context
        try? modelContext.save()
        
        // Verify persistence
        if let user = user {
            user.verifyImageData()
        }
    }
    
    private func deleteUser(_ user: User) {
        // Delete all associated lists first
        if let lists = user.lists {
            for list in lists {
                modelContext.delete(list)
            }
        }
        
        // Delete the user
        modelContext.delete(user)
        
        // Save changes
        try? modelContext.save()
    }
}
