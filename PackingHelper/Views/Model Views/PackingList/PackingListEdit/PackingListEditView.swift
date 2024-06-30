//
//  PackingListCreateView.swift
//  PackingHelper
//
//  Created by Todd Louison on 11/9/23.
//

import SwiftUI
import SwiftData

struct PackingListEditView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var packingList: PackingList?
    var isTemplate: Bool = false
    
    var trip: Trip? = nil
    var forceListType: ListType? = nil
    
    @Query private var users: [User]
    @State private var selectedUser: User?
    
    @State private var listName = ""
    @State private var listType: ListType = .packing
    @State private var countAsDays: Bool = false
    
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
                    Section("List Details") {
                        TextField("List Name", text: $listName)
                        
                        if let forceListType {
                            HStack {
                                Text("List Type")
                                Spacer()
                                Text(forceListType.rawValue)
                                    .foregroundStyle(.secondary)
                            }
                        } else {
                            Picker("List Type", selection: $listType) {
                                ForEach(ListType.allCases, id: \.rawValue) { type in
                                    Text(type.rawValue).tag(type)
                                }
                            }
                        }
                    }
                    
                    Section("Packer") {
                        UserPickerBaseView(selectedUser: $selectedUser, allowAll: false)
                    }
                    
                    if isTemplate {
                        Section {
                            Toggle("Trip Duration as Item Count", isOn: $countAsDays)
                        } header: {
                            Text("Default List Options")
                        } footer: {
                            Text("If enabled, applying this list to a trip will set the amount of each item in this list to the number of days the trip will last. If disabled, 1 will be used for all items. These can be changed once the list is applied.")
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
                countAsDays = packingList.countAsDays
            } else {
                // If there is no list, we should get a default user
                if users.isEmpty {
                    // This state shouldn't be possible, but create a fallback user if we get here
                    let newUser = User(name: "Default Packer")
                    modelContext.insert(newUser)
                    selectedUser = newUser
                } else {
                    selectedUser = users.sorted(by: { $0.created < $1.created }).first!
                }
            }
            
            if let forceListType {
                listType = forceListType
            }
        }
        .alert("Delete \(packingList?.name ?? "list")?", isPresented: $isDeleting) {
            Button("Yes, delete \(packingList?.name ?? "list")", role: .destructive) {
                delete(packingList!)
            }
        }
    }
    
    func save() {
        PackingList.save(
            packingList,
            name: listName,
            type: listType,
            template: isTemplate,
            countAsDays: countAsDays,
            user: selectedUser!,
            in: modelContext,
            for: trip
        )
    }
    
    private func delete(_ packingList: PackingList) {
        isDeleted = PackingList.delete(packingList, from: modelContext)
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
    PackingListEditView(packingList: lists.first, isTemplate: true, isDeleted: .constant(false))
        .previewDevice(PreviewDevice(rawValue: "iPhone 14 Pro Max"))
        .previewDisplayName("Edit PackingList")
}
