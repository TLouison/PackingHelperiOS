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

    // Local state
    @State private var selectedUser: User?
    @State private var collapsedSections: Set<String> = []
    @State private var editingItemId: PersistentIdentifier?

    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var newItemUser: User? = nil
    @State private var newItemList: PackingList? = nil
    @FocusState private var isTextFieldFocused: Bool

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
        // Sort alphabetically by list name
        return filtered.sorted { $0.name.lowercased() < $1.name.lowercased() }
    }

    var allPackedItems: [Item] {
        var packedItems: [Item] = []
        for list in filteredLists {
            packedItems.append(contentsOf: list.completeItems)
        }
        return Item.sorted(packedItems, sortOrder: .byDate)
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
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // User selector if multiple packers
                if hasMultiplePackers {
                    UserSelector(
                        users: users ?? [],
                        selectedUser: $selectedUser
                    )
                }

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

                        // List sections
                        ForEach(filteredLists) { list in
                            PackingListSection(
                                packingList: list,
                                users: users,
                                isExpanded: isExpanded(for: list),
                                editingItemId: $editingItemId,
                                onTogglePacked: togglePacked,
                                onUpdateItem: updateItem,
                                onDeleteItem: deleteItem,
                                onEditList: { editingList = list },
                                onDeleteList: { deleteList(list) }
                            )
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
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle(title ?? "Packing")
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            if let firstList = filteredLists.first {
                PackingSummaryBar(packingList: firstList)
            }
        }
        .onAppear {
            loadCollapseState()
            // Initialize new item defaults
            newItemUser = users?.first
            newItemList = filteredLists.first
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
            let newItem = Item(name: newItemName, category: "", count: newItemCount, isPacked: false)
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
