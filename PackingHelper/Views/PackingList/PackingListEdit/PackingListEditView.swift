//
//  PackingListCreateView.swift
//  PackingHelper
//
//  Created by Todd Louison on 11/9/23.
//

import SwiftUI
import SwiftData

struct PackingListEditView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var packingList: PackingList?
    var isTemplate: Bool = false
    
    var trip: Trip? = nil
    
    @Query private var users: [User]
    @State private var selectedUser: User?
    
    @State private var listName = ""
    @State private var listType: ListType = .packing
    
    @State private var isDeleting: Bool = false
    @Binding var isDeleted: Bool
    
    var formIsValid: Bool {
        return !listName.isEmpty
    }
    
    var titleString: String {
        packingList == nil ? "Add List" : "Edit List"
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Form {
                    TextField("List Name", text: $listName)
                    Picker("List Type", selection: $listType) {
                        ForEach(ListType.allCases, id: \.rawValue) { type in
                            Text(type.rawValue).tag(type)
                        }
                    }
                    Picker("Packer", selection: $selectedUser) {
                        ForEach(users, id: \.id) { user in
                            Text(user.name).tag(user as User?)
                        }
                    }
                }
                
                Spacer()
                
                if packingList != nil {
                    Button("Delete", role: .destructive) {
                        isDeleting.toggle()
                    }
                    .roundedBox()
                    .shaded()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text(titleString)
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
        }
        .onAppear {
            if let packingList {
                // Edit the incoming item.
                selectedUser = packingList.user
                listName = packingList.name
                listType = packingList.type
            } else {
                // If there is no list, we should get a default user
                if users.isEmpty {
                    // This state shouldn't be possible, but create a fallback user if we get here
                    let newUser = User(name: "Default Packer")
                    modelContext.insert(newUser)
                    selectedUser = newUser
                } else {
                    selectedUser = users.first!
                }
            }
        }
        .alert("Delete \(packingList?.name ?? "list")?", isPresented: $isDeleting) {
            Button("Yes, delete \(packingList?.name ?? "list")", role: .destructive) {
                delete(packingList!)
            }
        }
    }
    
    func save() {
        if let packingList {
            packingList.name = listName
            packingList.type = listType
            packingList.user = selectedUser!
        } else {
            let newPackingList = PackingList(type: listType, template: isTemplate, name: listName)
            newPackingList.user = selectedUser!
            
            modelContext.insert(newPackingList)
            
            if let trip {
                trip.addList(newPackingList)
            }
        }
    }
    
    private func delete(_ packingList: PackingList) {
        trip?.removeList(packingList)
        modelContext.delete(packingList)
        try? modelContext.save()
        isDeleted = true
        dismiss()
    }
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
    PackingListEditView(isDeleted: .constant(false))
        .previewDevice(PreviewDevice(rawValue: "iPhone 14"))
        .previewDisplayName("New PackingList")
}

@available(iOS 18.0, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var lists: [PackingList]
    PackingListEditView(packingList: lists.first, isDeleted: .constant(false))
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
        .previewDisplayName("Edit PackingList")
}
