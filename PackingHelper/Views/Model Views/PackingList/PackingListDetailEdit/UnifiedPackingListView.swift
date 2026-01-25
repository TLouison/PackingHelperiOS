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
    let users: [User]?

    let listType: ListType
    let isDayOf: Bool
    let title: String?

    let mode: UnifiedPackingListMode

    // Bindings from container (optional - for shared toolbar)
    @Binding var isAddingNewItem: Bool
    @Binding var editingList: PackingList?
    @Binding var showingAddListSheet: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    @Binding var selectedUser: User?

    // Local state
    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var newItemUser: User? = nil
    @State private var newItemList: PackingList? = nil
    @State private var shouldRefocusNewItem = false

    @FocusState private var isTextFieldFocused: Bool
    @State private var editingItemId: PersistentIdentifier?

    // For standalone mode (templating/detail) - stores lists passed in
    @State private var standaloneLists: [PackingList] = []
    @State private var localIsAddingNewItem = false
    @State private var localEditingList: PackingList? = nil
    @State private var localShowingAddListSheet = false
    @State private var localIsApplyingDefaultPackingList = false

    private var lists: [PackingList] {
        if let trip = trip {
            return trip.lists ?? []
        } else {
            return standaloneLists
        }
    }

    private var effectiveIsAddingNewItem: Bool {
        // Use bound value for .unified and .templating modes, local value for .detail mode
        (mode == .unified || mode == .templating) ? isAddingNewItem : localIsAddingNewItem
    }

    init(
        trip: Trip? = nil,
        lists: [PackingList] = [],
        users: [User]?,
        listType: ListType,
        isDayOf: Bool,
        title: String?,
        mode: UnifiedPackingListMode,
        isAddingNewItem: Binding<Bool> = .constant(false),
        editingList: Binding<PackingList?> = .constant(nil),
        showingAddListSheet: Binding<Bool> = .constant(false),
        isApplyingDefaultPackingList: Binding<Bool> = .constant(false),
        selectedUser: Binding<User?> = .constant(nil)
    ) {
        self.trip = trip
        self._standaloneLists = State(initialValue: lists)
        self.users = users
        self.listType = listType
        self.isDayOf = isDayOf
        self.title = title
        self.mode = mode
        self._isAddingNewItem = isAddingNewItem
        self._editingList = editingList
        self._showingAddListSheet = showingAddListSheet
        self._isApplyingDefaultPackingList = isApplyingDefaultPackingList
        self._selectedUser = selectedUser
    }
    
    var hasMultiplePackers: Bool {
        guard let users = users else { return false }
        return users.count > 1
    }
    
    var filteredLists: [PackingList] {
        let filtered = lists.filter { list in
            let typeMatch = list.type == listType && list.isDayOf == isDayOf
            if let selectedUser = selectedUser {
                return list.user == selectedUser && typeMatch
            } else {
                return typeMatch
            }
        }
        AppLogger.views.debug("Found \(filtered.count) filtered lists")
        for list in filtered {
            AppLogger.views.debug(" - \(list.name)")
        }
        return PackingList.sorted(filtered, sortOrder: .byDate)
    }
    
    var allItems: [Item] {
        var allItems: [Item] = []
        for list in filteredLists {
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
        ScrollView {
            VStack(spacing: 16) {
                // Add new item section
                if effectiveIsAddingNewItem {
                    NewItemRow(
                        itemName: $newItemName,
                        itemCount: $newItemCount,
                        itemUser: $newItemUser,
                        itemList: $newItemList,
                        shouldRefocus: $shouldRefocusNewItem,
                        listOptions: filteredLists,
                        showUserPicker: hasMultiplePackers,
                        onCommit: { action in
                            switch action {
                            case .saveAndContinue:
                                if let list = newItemList {
                                    addNewItemAndContinue(to: list)
                                }
                            case .saveAndClose:
                                if let list = newItemList {
                                    addNewItemAndClose(to: list)
                                }
                            case .cancel:
                                cancelAddingNewItem()
                            }
                        }
                    )
                    .transition(.asymmetric(
                        insertion: .move(edge: .top).combined(with: .opacity),
                        removal: .opacity
                    ))
                }

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

                    // Empty state
                    if (allItems.isEmpty && !effectiveIsAddingNewItem) {
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
                    if (packedItems.isEmpty && unpackedItems.isEmpty && !effectiveIsAddingNewItem) {
                        Spacer()
                        EmptyStateView()
                    }
                }
            }
            .padding(.horizontal)
        }
        .onAppear {
            // New items get first user and first matching list by default
            newItemUser = users?.first
            newItemList = filteredLists.first
        }
        .onChange(of: effectiveIsAddingNewItem) { _, isAdding in
            if isAdding {
                isTextFieldFocused = true
            }
        }
    }
    
    private func startAddingNewItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            if mode == .unified || mode == .templating {
                isAddingNewItem = true
            } else {
                localIsAddingNewItem = true
            }
            isTextFieldFocused = true
        }
    }

    private func addNewItemAndContinue(to list: PackingList) {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            // Empty text on Enter: just refocus, don't save
            shouldRefocusNewItem = true
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

            // Reset for next item but keep row open
            newItemName = ""
            newItemCount = 1
            // Do NOT set isAddingNewItem = false
        }

        // Trigger refocus after animation completes
        shouldRefocusNewItem = true
    }

    private func addNewItemAndClose(to list: PackingList) {
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

            // Reset fields and close the input row
            newItemName = ""
            newItemCount = 1
            if mode == .unified || mode == .templating {
                isAddingNewItem = false
            } else {
                localIsAddingNewItem = false
            }
            isTextFieldFocused = false
        }
    }

    private func cancelAddingNewItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            newItemName = ""
            newItemCount = 1
            if mode == .unified || mode == .templating {
                isAddingNewItem = false
            } else {
                localIsAddingNewItem = false
            }
            isTextFieldFocused = false
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
            SortOrderManager.reorderUnifiedItems(in: filteredLists, moving: item, to: newIndex, includeAllItems: includeAll)
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

struct AddPackingListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    let trip: Trip
    let listType: ListType
    let isDayOf: Bool

    let users: [User]?
    let onAdd: (PackingList) -> Void

    @State private var listName = ""
    @State private var listUser: User?
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                TextField("List Name", text: $listName)
                    .focused($isFocused)
                
                UserPickerView(selectedUser: $listUser, style: .inline, allowAll: false)
            }
            .navigationTitle("New \(listType.localizedDisplayName) List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        addList()
                    }
                    .fontWeight(.medium)
                    .disabled(listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || listUser == nil)
                }
            }
        }
        .onAppear {
            if listUser == nil {
                listUser = users?.first
            }
            isFocused = true
        }
    }
    
    private func addList() {
        let newList = PackingList(type: listType, template: false, name: listName, countAsDays: false, isDayOf: isDayOf)
        if let user = listUser {
            newList.user = user
        }
        modelContext.insert(newList)
        trip.addList(newList)

        onAdd(newList)
        dismiss()
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

