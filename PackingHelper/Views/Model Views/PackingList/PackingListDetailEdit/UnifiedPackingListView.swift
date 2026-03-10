//
//  UnifiedPackingListView.swift
//  PackingHelper
//
//  A view that allows multiple modes of use:
//      1. Unified packing (the default). Pass in multiple lists, optionally pass in
//          the users of those lists, and be able to edit all the lists in a single
//          unified interface.
//      2. Detailed edit. Used when you want to edit just a single list. Pass in a
//          single list, no users, and editing will work!
//
//  Created by Todd Louison on 9/16/25.
//

import SwiftUI
import SwiftData
import OSLog

enum UnifiedPackingListMode: String {
    case unified, detail, templating
}

struct UnifiedPackingListView: View {
    @Environment(\.modelContext) private var modelContext

    let trip: Trip?
    let lists: [PackingList]
    let users: [User]?

    let title: String?

    let mode: UnifiedPackingListMode

    // Bindings from container (optional - for shared toolbar)
    @Binding var isAddingNewItem: Bool
    @Binding var editingList: PackingList?
    @Binding var showingAddListSheet: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    @Binding var selectedUser: User?
    @Binding var scrollToPlaceholder: Bool

    // Local state
    @State private var editingItemId: PersistentIdentifier?

    // Target list for placeholder display (set by container)
    let newItemList: PackingList?

    init(
        trip: Trip? = nil,
        lists: [PackingList] = [],
        users: [User]?,
        title: String?,
        mode: UnifiedPackingListMode,
        newItemList: PackingList? = nil,
        isAddingNewItem: Binding<Bool> = .constant(false),
        editingList: Binding<PackingList?> = .constant(nil),
        showingAddListSheet: Binding<Bool> = .constant(false),
        isApplyingDefaultPackingList: Binding<Bool> = .constant(false),
        selectedUser: Binding<User?> = .constant(nil),
        scrollToPlaceholder: Binding<Bool> = .constant(false)
    ) {
        self.trip = trip
        self.lists = lists
        self.users = users
        self.title = title
        self.mode = mode
        self.newItemList = newItemList
        self._isAddingNewItem = isAddingNewItem
        self._editingList = editingList
        self._showingAddListSheet = showingAddListSheet
        self._isApplyingDefaultPackingList = isApplyingDefaultPackingList
        self._selectedUser = selectedUser
        self._scrollToPlaceholder = scrollToPlaceholder
    }
    
    var hasMultiplePackers: Bool {
        guard let users = users else { return false }
        return users.count > 1
    }
    
    var sortedLists: [PackingList] {
        return PackingList.sorted(lists, sortOrder: .byDate)
    }
    
    var allItems: [Item] {
        var allItems: [Item] = []
        for list in sortedLists {
            if let items = list.items {
                allItems.append(contentsOf: items)
            }
        }
        // Sort by unified order for proper display after reordering
        return Item.sorted(allItems, sortOrder: .byUnifiedOrder)
    }
    
    func getFilteredItems(packed: Bool) -> [Item] {
        let filteredItems = allItems.filter { item in
            packed ? item.isPacked : !item.isPacked
        }
        return Item.sorted(filteredItems, sortOrder: .byUnifiedOrder)
    }
    
    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                VStack(spacing: 16) {
                    // If we are working on a template, put all items in a section
                    // together. Otherwise, separate them by packed/unpacked
                    if mode == .templating {
                        ReorderableItemsSection(
                            items: allItems,
                            mode: mode,
                            editingItemId: $editingItemId,
                            onTogglePacked: togglePacked,
                            onUpdateItem: updateItem,
                            onDeleteItem: deleteItem,
                            onReorder: handleUnifiedReorder
                        )

                        // Insertion placeholder (templating mode)
                        if isAddingNewItem {
                            InsertionPlaceholder()
                                .id("insertionPlaceholder")
                        }

                        // Empty state
                        if (allItems.isEmpty && !isAddingNewItem) {
                            EmptyStateView()
                                .padding(.top, 60)
                        }
                    } else {
                        // Unpacked items
                        let unpackedItems = getFilteredItems(packed: false)
                        if !unpackedItems.isEmpty {
                            ReorderableItemsSection(
                                items: unpackedItems,
                                mode: mode,
                                editingItemId: $editingItemId,
                                onTogglePacked: togglePacked,
                                onUpdateItem: updateItem,
                                onDeleteItem: deleteItem,
                                onReorder: handleUnifiedReorder
                            )
                        }

                        // Insertion placeholder (after unpacked items)
                        if isAddingNewItem {
                            InsertionPlaceholder()
                                .id("insertionPlaceholder")
                        }

                        let packedItems = getFilteredItems(packed: true)
                        // Packed items
                        if !packedItems.isEmpty {
                            PackedItemsSection(
                                items: packedItems,
                                onTogglePacked: togglePacked,
                                onDeleteItem: deleteItem
                            )
                        }

                        // Empty state
                        if (packedItems.isEmpty && unpackedItems.isEmpty && !isAddingNewItem) {
                            Spacer()
                            EmptyStateView()
                        }
                    }
                }
                .padding(.horizontal, 8)
            }
            .onChange(of: isAddingNewItem) { _, isAdding in
                if isAdding {
                    withAnimation {
                        proxy.scrollTo("insertionPlaceholder", anchor: .bottom)
                    }
                }
            }
            .onChange(of: newItemList) { _, _ in
                if isAddingNewItem {
                    withAnimation {
                        proxy.scrollTo("insertionPlaceholder", anchor: .bottom)
                    }
                }
            }
            .onChange(of: scrollToPlaceholder) { _, shouldScroll in
                if shouldScroll {
                    scrollToPlaceholder = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            proxy.scrollTo("insertionPlaceholder", anchor: .bottom)
                        }
                    }
                }
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

    private func handleUnifiedReorder(item: Item, newIndex: Int) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            // For templating/detail mode, include all items; for unified mode, only unpacked items
            let includeAll = (mode == .templating || mode == .detail)
            SortOrderManager.reorderUnifiedItems(in: sortedLists, moving: item, to: newIndex, includeAllItems: includeAll)
        }
    }
}

struct UserSelector: View {
    let users: [User]
    @Binding var selectedUser: User?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(users.sorted { $0.name < $1.name }) { user in
                    user.pillIcon
                        .scaleEffect(user == selectedUser ? 1.3 : 1.0)
                        .opacity(user == selectedUser || selectedUser == nil ? 1.0 : 0.3)
                        .onTapGesture {
                            if selectedUser != user {
                                DispatchQueue.main.async {
                                    withAnimation {
                                        self.selectedUser = user
                                    }
                                }
                            } else {
                                withAnimation {
                                    self.selectedUser = nil
                                }
                            }
                        }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(Color(UIColor.systemBackground))
        .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
    }
}

// MARK: - View for displaying items with edit capabilities

struct UnpackedItemsSection: View {
    let items: [Item]
    var mode: UnifiedPackingListMode = .unified
    
    @Binding var editingItemId: PersistentIdentifier?
    let onTogglePacked: (Item) -> Void
    let onUpdateItem: (Item, String, Int) -> Void
    let onDeleteItem: (Item) -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            ForEach(items) { item in
                if editingItemId == item.persistentModelID {
                    EditableItemRow(
                        item: item,
                        mode: mode,
                        onCommit: { name, count in
                            onUpdateItem(item, name, count)
                        },
                        onCancel: {
                            editingItemId = nil
                        }
                    )
                } else {
                    UnifiedItemRow(
                        item: item,
                        mode: mode,
                        onTogglePacked: { onTogglePacked(item) },
                        onEdit: { editingItemId = item.persistentModelID },
                        onDelete: { onDeleteItem(item) }
                    )
                }
            }
        }
    }
}

struct EmptyStateView: View {
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "shippingbox")
                .font(.system(size: 60))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("You haven't added any items yet!")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Tap the + button to add your first item")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
    }
}

struct NoListSelectedView: View {
    let onCreateList: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "list.bullet.rectangle")
                .font(.system(size: 80))
                .foregroundColor(.gray.opacity(0.3))
            
            Text("No Packing Lists")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Create your first packing list to get started")
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onCreateList) {
                Label("Create List", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
        }
        .padding()
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
                .padding(.horizontal, 4)
            }
            
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(items) { item in
                        UnifiedItemRow(
                            item: item,
                            mode: .unified,
                            onTogglePacked: { onTogglePacked(item) },
                            onEdit: { },
                            onDelete: { onDeleteItem(item) }
                        )
                        .opacity(0.6)
                    }
                }
            }
        }
    }
}

private struct CategoryChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption)
                .fontWeight(.medium)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(isSelected ? Color.blue : Color.gray.opacity(0.2))
                .foregroundColor(isSelected ? .white : .primary)
                .cornerRadius(15)
        }
    }
}

