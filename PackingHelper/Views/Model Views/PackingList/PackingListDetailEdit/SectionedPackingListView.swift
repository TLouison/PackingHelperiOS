//
//  SectionedPackingListView.swift
//  PackingHelper
//
//  A view that displays packing items grouped by their parent list names
//  as collapsible sections, similar to Apple Reminders. This is separate
//  from UnifiedPackingListView which shows a flat list organized by
//  packed/unpacked status.
//
//  Created by Claude on 1/11/26.
//

import SwiftUI
import SwiftData

struct SectionedPackingListView: View {
    @Environment(\.modelContext) private var modelContext

    let users: [User]?
    let listType: ListType
    let isDayOf: Bool
    let title: String?
    let trip: Trip

    // Bindings from container
    @Binding var isAddingNewItem: Bool
    @Binding var editingList: PackingList?
    @Binding var showingAddListSheet: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    @Binding var selectedUser: User?
    @Binding var isReorderingSections: Bool

    // Local state
    @State private var collapsedSections: Set<String> = []
    @State private var expandedSectionsBeforeReorder: Set<String> = []
    @State private var editingItemId: PersistentIdentifier?
    @State private var draggedList: PackingList?

    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var newItemUser: User? = nil
    @State private var newItemList: PackingList? = nil
    @FocusState private var isTextFieldFocused: Bool

    @State private var isShowingSaveSuccessful: Bool = false

    var hasMultiplePackers: Bool {
        guard let users = users else { return false }
        return users.count > 1
    }

    private var lists: [PackingList] {
        trip.lists ?? []
    }

    var filteredLists: [PackingList] {
        let filtered = lists.filter { list in
            let typeMatch = list.type == listType && list.isDayOf == isDayOf
            if let selectedUser = selectedUser {
                return list.user == selectedUser && typeMatch
            }
            return typeMatch
        }
        // Sort by custom order for manual reordering
        return PackingList.sorted(filtered, sortOrder: .byCustomOrder)
    }

    var allPackedItems: [Item] {
        var packedItems: [Item] = []
        for list in filteredLists {
            packedItems.append(contentsOf: list.completeItems)
        }
        return Item.sorted(packedItems, sortOrder: .byCustomOrder)
    }

    func isExpanded(for list: PackingList) -> Binding<Bool> {
        Binding(
            get: { !collapsedSections.contains(String(list.persistentModelID.hashValue)) },
            set: { expanded in
                let id = String(list.persistentModelID.hashValue)
                if expanded {
                    collapsedSections.remove(id)
                } else {
                    collapsedSections.insert(id)
                }
                SectionCollapseStateManager.saveCollapsedSections(collapsedSections, for: trip.persistentModelID)
            }
        )
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 8) {
                // Add new item section (global)
                if isAddingNewItem {
                    NewItemRow(
                        itemName: $newItemName,
                        itemCount: $newItemCount,
                        itemUser: $newItemUser,
                        itemList: $newItemList,
                        listOptions: filteredLists,
                        showUserPicker: hasMultiplePackers,
                        onCommit: {
                            if let list = newItemList {
                                addNewItem(to: list)
                            }
                        },
                        onCancel: cancelAddingNewItem
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                }

                // List sections with drag-and-drop reordering
                ForEach(Array(filteredLists.enumerated()), id: \.element.id) { index, list in
                    VStack(spacing: 0) {
                        // Drop zone before first section
                        if isReorderingSections && index == 0 {
                            SectionDropZone(
                                insertionIndex: 0,
                                isDragging: true,
                                onDrop: { droppedList in
                                    handleSectionReorder(list: droppedList, to: 0)
                                }
                            )
                        }

                        PackingListSection(
                            packingList: list,
                            users: users,
                            isExpanded: isExpanded(for: list),
                            editingItemId: $editingItemId,
                            onTogglePacked: togglePacked,
                            onUpdateItem: updateItem,
                            onDeleteItem: deleteItem,
                            onEditList: { editingList = list },
                            onDeleteList: { deleteList(list) },
                            onSaveAsDefault: { saveListAsDefault(list) },
                            onItemReorder: handleItemReorder,
                            onCrossListDrop: handleCrossListMove,
                            isReorderMode: isReorderingSections
                        )
                        .draggable(PackingListTransferData(list: list)) {
                            // Section drag preview
                            PackingListSectionHeader(
                                packingList: list,
                                isExpanded: .constant(false),
                                onAddItem: {},
                                onEditList: {},
                                onDeleteList: {},
                                onSaveAsDefault: {}
                            )
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(.ultraThickMaterial)
                            .cornerRadius(12)
                        }
                        .onAppear {
                            // Track when dragging starts
                            if draggedList?.persistentModelID == list.persistentModelID {
                                draggedList = list
                            }
                        }

                        // Drop zone after each section
                        if isReorderingSections {
                            SectionDropZone(
                                insertionIndex: index + 1,
                                isDragging: true,
                                onDrop: { droppedList in
                                    handleSectionReorder(list: droppedList, to: index + 1)
                                }
                            )
                        }
                    }
                }

                // Global packed items section
                if !allPackedItems.isEmpty {
                    PackedItemsSection(
                        items: allPackedItems,
                        onTogglePacked: togglePacked,
                        onDeleteItem: deleteItem
                    )
                    .padding(.top, 8)
                }

                // Empty state
                if filteredLists.allSatisfy({ ($0.items?.isEmpty ?? true) }) && !isAddingNewItem {
                    EmptyStateView()
                        .padding(.top, 60)
                }
            }
            .padding()
        }
        .onAppear {
            loadCollapseState()
            // Initialize new item defaults
            newItemUser = users?.first
            newItemList = filteredLists.first
        }
        .onChange(of: isReorderingSections) { _, isReordering in
            if isReordering {
                enterReorderMode()
            } else {
                exitReorderMode()
            }
        }
        .alert("List saved as default", isPresented: $isShowingSaveSuccessful) {
            Button("OK", role: .cancel) {}
        }
    }

    private func loadCollapseState() {
        collapsedSections = SectionCollapseStateManager.loadCollapsedSections(for: trip.persistentModelID)

        // Auto-collapse empty lists
        for list in filteredLists where (list.items?.isEmpty ?? true) {
            let id = String(list.persistentModelID.hashValue)
            if !collapsedSections.contains(id) {
                collapsedSections.insert(id)
            }
        }
    }

    private func togglePacked(_ item: Item) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            item.isPacked.toggle()
        }
    }

    private func updateItem(_ item: Item, name: String, count: Int) {
        withAnimation {
            item.name = name
            item.count = count
            editingItemId = nil
        }
    }

    private func deleteItem(_ item: Item) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            modelContext.delete(item)
        }
    }

    private func deleteList(_ list: PackingList) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            modelContext.delete(list)
        }
    }

    private func saveListAsDefault(_ list: PackingList) {
        withAnimation {
            let newDefaultList = PackingList.copyAsTemplate(list)
            modelContext.insert(newDefaultList)
            isShowingSaveSuccessful = true
        }
    }

    private func startAddingNewItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            isAddingNewItem = true
            isTextFieldFocused = true
        }
    }

    private func addNewItem(to list: PackingList) {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelAddingNewItem()
            return
        }

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // Calculate next sort orders
            let nextSortOrder = SortOrderManager.nextSortOrder(for: list)
            let nextUnifiedSortOrder = SortOrderManager.nextUnifiedSortOrder(in: filteredLists)

            let newItem = Item(
                name: newItemName,
                category: "",
                count: newItemCount,
                isPacked: false,
                sortOrder: nextSortOrder,
                unifiedSortOrder: nextUnifiedSortOrder
            )
            modelContext.insert(newItem)
            list.addItem(newItem)

            newItemName = ""
            newItemCount = 1
            isAddingNewItem = false
            isTextFieldFocused = false
        }
    }

    private func cancelAddingNewItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            newItemName = ""
            newItemCount = 1
            isAddingNewItem = false
            isTextFieldFocused = false
        }
    }

    private func handleItemReorder(item: Item, in list: PackingList, to newIndex: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            print("Trying to reorder item \(item.name)")
            SortOrderManager.reorderItems(in: list, moving: item, to: newIndex)
        }
    }

    private func handleCrossListMove(item: Item, to targetList: PackingList, at index: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            print("Trying to reorder item into list \(targetList.name) with name \(item.name)")
            SortOrderManager.moveItem(item, to: targetList, at: index)
        }
    }

    private func handleSectionReorder(list: PackingList, to newIndex: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            print("Trying to reorder section with name: \(list.name)")
            var mutableLists = filteredLists
            SortOrderManager.reorderLists(&mutableLists, moving: list, to: newIndex)
        }
    }

    private func enterReorderMode() {
        // Save which sections are currently expanded
        expandedSectionsBeforeReorder = Set(filteredLists.compactMap { list in
            let id = String(list.persistentModelID.hashValue)
            return collapsedSections.contains(id) ? nil : id
        })
        // Collapse all sections
        withAnimation {
            for list in filteredLists {
                collapsedSections.insert(String(list.persistentModelID.hashValue))
            }
        }
    }

    private func exitReorderMode() {
        // Restore previously expanded sections
        withAnimation {
            collapsedSections = collapsedSections.subtracting(expandedSectionsBeforeReorder)
            expandedSectionsBeforeReorder = []
        }
        SectionCollapseStateManager.saveCollapsedSections(collapsedSections, for: trip.persistentModelID)
    }
}

private struct PackedItemsSection: View {
    let items: [Item]
    let onTogglePacked: (Item) -> Void
    let onDeleteItem: (Item) -> Void

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack {
                    Text("PACKED ITEMS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)

                    Spacer()

                    Text("\(items.count)")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(items) { item in
                        UnifiedItemRow(
                            item: item,
                            mode: .unified,
                            onTogglePacked: { onTogglePacked(item) },
                            onEdit: {},
                            onDelete: { onDeleteItem(item) }
                        )
                        .opacity(0.6)
                        .padding(.horizontal)
                    }
                }
            }
        }
        .roundedBox()
        .shaded()
        .padding(.horizontal)
    }
}
