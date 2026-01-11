//
//  ItemRowViews.swift
//  PackingHelper
//
//  Created by Todd Louison on 9/17/25.
//

import SwiftUI
import SwiftData

struct NewItemRow: View {
    @Binding var itemName: String
    @Binding var itemCount: Int
    @Binding var itemUser: User?
    @Binding var itemList: PackingList?
    
    let listOptions: [PackingList]
    let showUserPicker: Bool
    
    @FocusState var isFocused: Bool
    let onCommit: () -> Void
    let onCancel: () -> Void
    
    var visibleLists: [PackingList] {
        listOptions.filter{ $0.user == itemUser }
    }
    
    var showListSelector: Bool {
        listOptions.count > 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                TextField("Item name", text: $itemName)
                    .focused($isFocused)
                    .onSubmit(onCommit)
                
                Stepper(value: $itemCount, in: 1...99) {
                    Text("\(itemCount)")
                        .foregroundColor(.secondary)
                        .frame(minWidth: 30)
                }
                
                Button(action: onCommit) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .opacity(itemName.isEmpty ? 0.3 : 1.0)
                .disabled(itemName.isEmpty)
            }
            
            if showListSelector || showUserPicker {
                HStack {
                    if showListSelector {
                        Picker("Packing List", selection: $itemList) {
                            ForEach(visibleLists, id: \.id) { list in
                                Text(list.name)
                                    .tag(list)
                            }
                        }
                        .onChange(of: itemUser) {
                            itemList = visibleLists.first
                        }
                    }
                    
                    
                    Spacer()
                    
                    if showUserPicker {
                        UserPickerView(selectedUser: $itemUser, style: .menu, allowAll: false)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
}


struct EditableItemRow: View {
    let item: Item
    let mode: UnifiedPackingListMode
    let onCommit: (String, Int) -> Void
    let onCancel: () -> Void
    
    @State private var editName: String
    @State private var editCount: Int
    @FocusState private var isFocused: Bool
    
    init(item: Item, mode: UnifiedPackingListMode, onCommit: @escaping (String, Int) -> Void, onCancel: @escaping () -> Void) {
        self.item = item
        self.mode = mode
        self.onCommit = onCommit
        self.onCancel = onCancel
        self._editName = State(initialValue: item.name)
        self._editCount = State(initialValue: item.count)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if mode != .templating {
                Image(systemName: item.isPacked ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(item.isPacked ? .blue : .gray.opacity(0.5))
            }
            
            TextField("Item name", text: $editName)
                .focused($isFocused)
                .onSubmit {
                    onCommit(editName, editCount)
                }
            
            Stepper(value: $editCount, in: 1...99) {
                Text("\(editCount)")
                    .foregroundColor(.secondary)
                    .frame(minWidth: 30)
            }
            
            Button(action: {
                onCommit(editName, editCount)
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
        .onAppear {
            isFocused = true
        }
    }
}

struct UnifiedItemRow: View {
    let item: Item
    let mode: UnifiedPackingListMode
    let onTogglePacked: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            if mode != .templating {
                Image(systemName: item.isPacked ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(item.isPacked ? .blue : .gray.opacity(0.5))
                    .onTapGesture(perform: onTogglePacked)
            }
            
            Text(item.name)
                .strikethrough(item.isPacked)
                .foregroundColor(item.isPacked ? .gray : .primary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .contentShape(Rectangle())
                .onTapGesture(perform: onEdit)
            
            if item.count > 1 {
                Text("\(item.count)")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
    }
}
