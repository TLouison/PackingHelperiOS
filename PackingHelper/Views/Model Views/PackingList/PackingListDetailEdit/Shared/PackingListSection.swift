//
//  PackingListSection.swift
//  PackingHelper
//
//  Created by Claude on 1/11/26.
//

import SwiftUI
import SwiftData

struct PackingListSection: View {
    @Environment(\.modelContext) private var modelContext

    let packingList: PackingList
    let users: [User]?
    @Binding var isExpanded: Bool
    @Binding var editingItemId: PersistentIdentifier?

    let onTogglePacked: (Item) -> Void
    let onUpdateItem: (Item, String, Int) -> Void
    let onDeleteItem: (Item) -> Void
    let onEditList: () -> Void
    let onDeleteList: () -> Void

    @State private var isAddingItem = false
    @State private var newItemName = ""
    @State private var newItemCount = 1

    private var unpackedItems: [Item] {
        packingList.incompleteItems
    }

    private var isEmpty: Bool {
        packingList.items?.isEmpty ?? true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Section header
            PackingListSectionHeader(
                packingList: packingList,
                isExpanded: $isExpanded,
                onAddItem: startAddingItem,
                onEditList: onEditList,
                onDeleteList: onDeleteList
            )
            
            Divider()

            if isExpanded {
                // New item row
                if isAddingItem {
                    NewItemRow(
                        itemName: $newItemName,
                        itemCount: $newItemCount,
                        itemUser: .constant(nil),
                        itemList: .constant(packingList),
                        listOptions: [packingList],
                        showUserPicker: false,
                        onCommit: addNewItem,
                        onCancel: cancelAddingItem
                    )
                    .padding(.horizontal)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                }

                // Unpacked items
                if unpackedItems.isEmpty && !isAddingItem {
                    Text("No items")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .padding(.horizontal)
                        .padding(.vertical, 8)
                } else {
                    VStack(spacing: 4) {
                        ForEach(unpackedItems) { item in
                            if editingItemId == item.persistentModelID {
                                EditableItemRow(
                                    item: item,
                                    mode: .unified,
                                    onCommit: { name, count in
                                        onUpdateItem(item, name, count)
                                    },
                                    onCancel: {
                                        editingItemId = nil
                                    }
                                )
                                .padding(.horizontal)
                            } else {
                                UnifiedItemRow(
                                    item: item,
                                    mode: .unified,
                                    onTogglePacked: { onTogglePacked(item) },
                                    onEdit: { editingItemId = item.persistentModelID },
                                    onDelete: { onDeleteItem(item) }
                                )
                                .padding(.horizontal)
                            }
                        }
                    }
                }
            }
        }
    }

    private func startAddingItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isAddingItem = true
            isExpanded = true
        }
    }

    private func addNewItem() {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelAddingItem()
            return
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            let newItem = Item(name: newItemName, category: "", count: newItemCount, isPacked: false)
            modelContext.insert(newItem)

            packingList.addItem(newItem)

            // Reset fields
            newItemName = ""
            newItemCount = 1
            isAddingItem = false
        }
    }

    private func cancelAddingItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            newItemName = ""
            newItemCount = 1
            isAddingItem = false
        }
    }
}
