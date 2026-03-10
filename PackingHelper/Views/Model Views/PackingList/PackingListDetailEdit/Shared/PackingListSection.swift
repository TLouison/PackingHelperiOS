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
    let onAddItemToList: (PackingList) -> Void
    var isReorderMode: Bool = false

    // Placeholder display
    var isAddingNewItem: Bool = false
    var targetList: PackingList? = nil

    private var unpackedItems: [Item] {
        Item.sorted(packingList.incompleteItems, sortOrder: .byCustomOrder)
    }

    private var isTargetList: Bool {
        isAddingNewItem && targetList?.persistentModelID == packingList.persistentModelID
    }

    var body: some View {
        VStack(alignment: .leading, spacing: isReorderMode ? 4 : 12) {
            // Section header
            PackingListSectionHeader(
                packingList: packingList,
                isExpanded: $isExpanded,
                onAddItem: {
                    withAnimation { isExpanded = true }
                    onAddItemToList(packingList)
                },
                onEditList: onEditList,
                onDeleteList: onDeleteList,
                onSaveAsDefault: onSaveAsDefault,
                isReorderMode: isReorderMode
            )

            if !isReorderMode && isExpanded {
                Divider()

                // Unpacked items
                if unpackedItems.isEmpty && !isTargetList {
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
                    .padding(.horizontal, 8)
                }

                // Insertion placeholder
                if isTargetList {
                    InsertionPlaceholder()
                        .id("insertionPlaceholder-\(packingList.persistentModelID.hashValue)")
                }
            }
        }
        .padding(.vertical, 8)
    }
}
