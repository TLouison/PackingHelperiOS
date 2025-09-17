//
//  UnifiedPackingListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 9/16/25.
//

import SwiftUI
import SwiftData

struct UnifiedPackingListView: View {
    @Environment(\.modelContext) private var modelContext
    let trip: Trip
    let listType: ListType
    
    @State private var selectedUser: User?
    
    @State private var selectedList: PackingList?
    @State private var isAddingNewItem = false
    
    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var newItemUser: User? = nil
    @State private var newItemList: PackingList? = nil
    
    @FocusState private var isTextFieldFocused: Bool
    @State private var editingItemId: PersistentIdentifier?
    @State private var showingAddListSheet = false
    
    var filteredLists: [PackingList] {
        return PackingList.sorted(trip.getLists(for: selectedUser, ofType: listType), sortOrder: .byDate)
    }
    
    func getFilteredItems(packed: Bool) -> [Item] {
        let lists = filteredLists
        var allItems: [Item] = []
        for list in lists {
            if let items = list.items {
                allItems.append(contentsOf: items)
            }
        }
        let filteredItems = allItems.filter { item in
            packed ? item.isPacked : !item.isPacked
        }
        return Item.sorted(filteredItems, sortOrder: .byDate)
    }
    
    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // List selector
                UserSelector(
                    trip: trip,
                    selectedUser: $selectedUser,
                )
                
                ScrollView {
                    VStack(spacing: 16) {
                        // Add new item section
                        if isAddingNewItem {
                            NewItemRow(
                                itemName: $newItemName,
                                itemCount: $newItemCount,
                                itemUser: $newItemUser,
                                itemList: $newItemList,
                                listOptions: filteredLists,
                                isFocused: _isTextFieldFocused,
                                onCommit: { addNewItem(to: newItemList!) },
                                onCancel: cancelAddingNewItem
                            )
                            .transition(.asymmetric(
                                insertion: .move(edge: .top).combined(with: .opacity),
                                removal: .opacity
                            ))
                        }
                        
                        // Unpacked items
                        let unpackedItems = getFilteredItems(packed: false)
                        if !unpackedItems.isEmpty {
                            UnpackedItemsSection(
                                items: unpackedItems,
                                editingItemId: $editingItemId,
                                onTogglePacked: togglePacked,
                                onUpdateItem: updateItem,
                                onDeleteItem: deleteItem
                            )
                        }
                        
                        // Packed items
                        let packedItems = getFilteredItems(packed: true)
                        if !packedItems.isEmpty {
                            PackedItemsSection(
                                items: packedItems,
                                onTogglePacked: togglePacked,
                                onDeleteItem: deleteItem
                            )
                        }
                        
                        // Empty state
                        if (packedItems.isEmpty && unpackedItems.isEmpty && !isAddingNewItem) {
                            EmptyStateView()
                                .padding(.top, 60)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle(trip.name)
        .navigationBarTitleDisplayMode(.large)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: startAddingNewItem) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                }
            }
        }
        .overlay(alignment: .bottom) {
            if let selectedList = selectedList {
                PackingSummaryBar(packingList: selectedList)
            }
        }
        .sheet(isPresented: $showingAddListSheet) {
            AddPackingListSheet(trip: trip) { newList in
                selectedList = newList
            }
        }
        .onAppear {
            // New items get first user and first list by default
            newItemUser = trip.packers.first
            newItemList = trip.lists?.first
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
            newItem.list = list
            
            modelContext.insert(newItem)
            
            // Reset fields
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
}

struct UserSelector: View {
    let trip: Trip
    
    @Binding var selectedUser: User?
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(trip.packers.sorted{ $0.name < $1.name}) { user in
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

struct ListTab: View {
    let name: String
    let isSelected: Bool
    let itemCount: Int
    let packedCount: Int
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(name)
                    .font(.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                
                if itemCount > 0 {
                    Text("\(packedCount)/\(itemCount)")
                        .font(.caption2)
                        .foregroundColor(isSelected ? .blue : .secondary)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(isSelected ? Color.blue : Color.gray.opacity(0.1))
            .foregroundColor(isSelected ? .white : .primary)
            .cornerRadius(20)
        }
    }
}

struct NewItemRow: View {
    @Binding var itemName: String
    @Binding var itemCount: Int
    @Binding var itemUser: User?
    @Binding var itemList: PackingList?
    
    let listOptions: [PackingList]
    
    @FocusState var isFocused: Bool
    let onCommit: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                Image(systemName: "square")
                    .font(.title3)
                    .foregroundColor(.blue.opacity(0.3))
                
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
            
            HStack {
                Picker("Packing List", selection: $itemList) {
                    ForEach(listOptions.filter{ $0.user == itemUser }, id: \.self) { list in
                        Text(list.name)
                            .tag(list)
                    }
                }
                Spacer()
                UserPickerView(selectedUser: $itemUser, style: .menu, allowAll: false)
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
    }
}

struct UnpackedItemsSection: View {
    let items: [Item]
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
    let onAdd: (PackingList) -> Void
    
    @State private var listName = ""
    @State private var isTemplate = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationView {
            Form {
                TextField("List Name", text: $listName)
                    .focused($isFocused)
                
                Toggle("Save as Template", isOn: $isTemplate)
                    .tint(.blue)
                
                Section {
                    Text("This list will be added to your \(trip.name) trip.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("New Packing List")
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
                    .disabled(listName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
        .onAppear {
            isFocused = true
        }
    }
    
    private func addList() {
        let newList = PackingList(type: .packing, template: false, name: listName, countAsDays: false)
        newList.trip = trip
        
        modelContext.insert(newList)
        
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

private struct UnifiedItemRow: View {
    let item: Item
    let onTogglePacked: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isPacked ? "checkmark.square.fill" : "square")
                .font(.title3)
                .foregroundColor(item.isPacked ? .blue : .gray.opacity(0.5))
                .onTapGesture(perform: onTogglePacked)
            
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

private struct EditableItemRow: View {
    let item: Item
    let onCommit: (String, Int) -> Void
    let onCancel: () -> Void
    
    @State private var editName: String
    @State private var editCount: Int
    @FocusState private var isFocused: Bool
    
    init(item: Item, onCommit: @escaping (String, Int) -> Void, onCancel: @escaping () -> Void) {
        self.item = item
        self.onCommit = onCommit
        self.onCancel = onCancel
        self._editName = State(initialValue: item.name)
        self._editCount = State(initialValue: item.count)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: item.isPacked ? "checkmark.square.fill" : "square")
                .font(.title3)
                .foregroundColor(item.isPacked ? .blue : .gray.opacity(0.5))
            
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

private struct PackingSummaryBar: View {
    let packingList: PackingList
    
    var totalItems: Int {
        packingList.items?.count ?? 0
    }
    
    var packedItems: Int {
        packingList.items?.filter { $0.isPacked }.count ?? 0
    }
    
    var progress: Double {
        totalItems > 0 ? Double(packedItems) / Double(totalItems) : 0
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Progress bar
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(height: 4)
                    
                    Rectangle()
                        .fill(Color.blue)
                        .frame(width: geometry.size.width * progress, height: 4)
                }
            }
            .frame(height: 4)
            
            // Summary info
            HStack {
                Label("\(packedItems)/\(totalItems) packed", systemImage: "checkmark.square.fill")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if progress == 1.0 {
                    Label("Ready to go!", systemImage: "sparkles")
                        .font(.subheadline)
                        .foregroundColor(.green)
                }
            }
            .padding()
            .background(Color(UIColor.systemBackground))
        }
        .shadow(color: .black.opacity(0.1), radius: 5, y: -2)
    }
}

