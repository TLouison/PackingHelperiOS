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
    @State private var defaultLocation: TripLocation?
    @State private var showingLocationSearch = false
    
    
    @Query private var users: [User]
    let user: User?
    var isPresentedModally: Bool = false

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
                    Section("Name") {
                        TextField("Name", text: $name)
                    }

                    if FeatureFlags.shared.showingProfilePictures {
                        Section("Profile Picture") {
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
                    }

                    Section {
                        HStack {
                            Spacer()
                            UserColorPicker(selectedColor: $userColor)
                            Spacer()
                        }
                    } header: {
                        Text("Favorite Color")
                    } footer: {
                        Text("Set the color of your user icon to your favorite color!")
                    }

                    Section {
                        Button {
                            showingLocationSearch = true
                        } label: {
                            HStack {
                                if let location = defaultLocation {
                                    Text(location.name)
                                        .foregroundColor(.primary)
                                } else {
                                    Text("Set Default Location")
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.secondary)
                                    .font(.caption)
                            }
                        }
                    } header: {
                        Text("Default Origin")
                    } footer: {
                        Text("Automatically set this location as your origin for new trips.")
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
                if isPresentedModally {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel", role: .cancel) {
                            dismiss()
                        }
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
            .sheet(isPresented: $showingLocationSearch) {
                LocationSearchView(location: $defaultLocation)
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
                    defaultLocation = user.defaultLocation
                }
            }
        }
    }
    
    private var formIsValid: Bool {
        return name != ""
    }
    
    private func save() {
        User.create_or_update(user, name: name, color: userColor, profileImage: selectedImage, in: modelContext)

        // Update default location
        if let user = user {
            user.defaultLocation = defaultLocation
        } else {
            // For new users, the default location will be set after creation
            // We need to find the newly created user and set its default location
            if let newUser = users.first(where: { $0.name == name }) {
                newUser.defaultLocation = defaultLocation
            }
        }

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
