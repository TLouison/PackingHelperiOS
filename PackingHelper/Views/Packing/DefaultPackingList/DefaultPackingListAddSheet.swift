//
//  DefaultPackingListAddSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/21/23.
//

import SwiftUI

struct DefaultPackingListAddSheet: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    @State private var newListName = ""
    
    var formIsValid: Bool {
        return !newListName.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("List Name", text: $newListName)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("New Default List")
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
    }
    
    func save() {
        modelContext.insert(PackingList(template: true, name: newListName))
    }
}

#Preview {
    DefaultPackingListAddSheet()
}
