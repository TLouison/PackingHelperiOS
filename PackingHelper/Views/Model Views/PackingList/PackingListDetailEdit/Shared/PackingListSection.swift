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
    let onSaveAsDefault: () -> Void
    let onItemReorder: (Item, PackingList, Int) -> Void
    let onCrossListDrop: (Item, PackingList, Int) -> Void
    var isReorderMode: Bool = false

    @State private var isAddingItem = false
    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var shouldRefocusNewItem = false

    private var unpackedItems: [Item] {
        Item.sorted(packingList.incompleteItems, sortOrder: .byCustomOrder)
    }

    private var isEmpty: Bool {
        packingList.items?.isEmpty ?? true
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isReorderMode ? 4 : 12) {
            // Section header
            PackingListSectionHeader(
                packingList: packingList,
                isExpanded: $isExpanded,
                onAddItem: startAddingItem,
                onEditList: onEditList,
                onDeleteList: onDeleteList,
                onSaveAsDefault: onSaveAsDefault,
                isReorderMode: isReorderMode
            )

            if !isReorderMode && isExpanded{
                Divider()
                
                // New item row
                if isAddingItem {
                    NewItemRow(
                        itemName: $newItemName,
                        itemCount: $newItemCount,
                        itemUser: .constant(nil),
                        itemList: .constant(packingList),
                        shouldRefocus: $shouldRefocusNewItem,
                        listOptions: [packingList],
                        showUserPicker: false,
                        onCommit: { action in
                            switch action {
                            case .saveAndContinue:
                                addNewItemAndContinue()
                            case .saveAndClose:
                                addNewItemAndClose()
                            case .cancel:
                                cancelAddingItem()
                            }
                        }
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
                    ReorderableItemsSection(
                        items: unpackedItems,
                        mode: .unified,
                        targetList: packingList,
                        editingItemId: $editingItemId,
                        onTogglePacked: onTogglePacked,
                        onUpdateItem: onUpdateItem,
                        onDeleteItem: onDeleteItem,
                        onReorder: { item, index in
                            onItemReorder(item, packingList, index)
                        },
                        onCrossListMove: onCrossListDrop
                    )
                    .padding(.horizontal)
                }
            }
        }
        .roundedBox()
    }

    private func startAddingItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isAddingItem = true
            isExpanded = true
        }
    }

    private func addNewItemAndContinue() {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Empty text on Enter: just refocus, don't save
            shouldRefocusNewItem = true
            return
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Calculate next sort orders
            let nextSortOrder = SortOrderManager.nextSortOrder(for: packingList)
            let allLists = packingList.trip?.lists ?? [packingList]
            let nextUnifiedSortOrder = SortOrderManager.nextUnifiedSortOrder(in: allLists)

            let newItem = Item(
                name: newItemName,
                category: "",
                count: newItemCount,
                isPacked: false,
                sortOrder: nextSortOrder,
                unifiedSortOrder: nextUnifiedSortOrder
            )
            modelContext.insert(newItem)

            packingList.addItem(newItem)

            // Reset for next item but keep row open
            newItemName = ""
            newItemCount = 1
            // Do NOT set isAddingItem = false
        }

        // Trigger refocus after animation completes
        shouldRefocusNewItem = true
    }

    private func addNewItemAndClose() {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelAddingItem()
            return
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Calculate next sort orders
            let nextSortOrder = SortOrderManager.nextSortOrder(for: packingList)
            let allLists = packingList.trip?.lists ?? [packingList]
            let nextUnifiedSortOrder = SortOrderManager.nextUnifiedSortOrder(in: allLists)

            let newItem = Item(
                name: newItemName,
                category: "",
                count: newItemCount,
                isPacked: false,
                sortOrder: nextSortOrder,
                unifiedSortOrder: nextUnifiedSortOrder
            )
            modelContext.insert(newItem)

            packingList.addItem(newItem)

            // Reset fields and close the input row
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
