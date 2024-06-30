//
//  EditItemView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/20/24.
//

import SwiftUI

struct EditItemView: View {
    @Environment(\.dismiss) private var dismiss
    
    var item: Item?
    
    @State private var name: String = ""
    @State private var count: Int = 1
    
    var editorTitle: String {
        if let item = item {
            return "Edit Item: \(item.name)"
        } else {
            return "New Item"
        }
    }
    
    var formIsValid: Bool {
        return name != ""
    }
    
    var showCount: Bool {
        item?.list?.type != .task
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                HStack {
                    TextField("Item Name", text: $name)
                        .padding()
                        .onAppear {
                            if let item {
                                // Edit the incoming item.
                                name = item.name
                                count = item.count
                            }
                        }
                    
                    if showCount {
                        Spacer()
                        Divider()
                        PackingAddItemCountPickerView(itemCount: $count)
                    }
                }
                .frame(maxHeight: 55)
                .background(.thickMaterial)
                .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
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
                if let item {
                    // Edit the incoming item.
                    name = item.name
                    count = item.count
                }
            }
        }
    }
    
    private func save() {
        if let item {
            item.name = name
            item.count = count
        }
        // NOTE: THIS VIEW DOES NOT ALLOW US TO CREATE NEW ITEMS
        //       SINCE THEY SHOULD NEVER EXIST WITHOUT BEING
        //       TIED TO A LIST.
    }
}
