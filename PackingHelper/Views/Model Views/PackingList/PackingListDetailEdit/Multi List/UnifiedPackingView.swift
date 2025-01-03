import SwiftUI
import SwiftData

struct UnifiedPackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: Trip
    let listType: ListType
    
    @Binding var selectedUser: User?
    @State private var sortOrder: PackingListSortOrder = .byDate
    @State private var showingPackedItems = false
    @State private var viewStyle: ViewStyle = .unified
    @State private var showingAddItem = false
    @State private var showingNewList = false
    @State private var preselectedList: PackingList? = nil
    
    enum ViewStyle {
        case unified, byList
    }
    
    var showUserPill: Bool {
            // Only show when we have multiple packers AND no user filter
            let packersWithLists = Set(trip.getLists(for: nil, ofType: listType).compactMap { $0.user })
            return selectedUser == nil && packersWithLists.count > 1
        }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            Picker("View", selection: $showingPackedItems) {
                Text("To pack").tag(false)
                Text("Packed").tag(true)
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            // Main Content
            PackingListContent(
                trip: trip,
                listType: listType,
                selectedUser: selectedUser,
                showingPackedItems: showingPackedItems,
                viewStyle: viewStyle,
                sortOrder: sortOrder,
                showUserPill: showUserPill,
                preselectedList: $preselectedList,
                showingAddItem: $showingAddItem
            )
        }
        .navigationTitle(listType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    if let selectedUser {
                        switch listType {
                        case .packing:
                            Text("\(listType.rawValue) for ")
                        case .task:
                            Text("\(listType.rawValue)s for ")
                        case .dayOf:
                            Text("\(listType.rawValue) Tasks for ")
                        }
                        selectedUser.pillIcon
                    } else {
                        Text(listType.rawValue)
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                MainMenuButton(
                    viewStyle: $viewStyle,
                    selectedUser: $selectedUser,
                    sortOrder: $sortOrder,
                    trip: trip
                )
            }
        }
        .overlay(alignment: .bottom) {
            Button(action: { showingAddItem = true }) {
                Label("Add item", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .foregroundColor(.white)
                    .clipShape(Capsule())
            }
            .padding()
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(
                trip: trip,
                listType: listType,
                selectedUser: selectedUser,
                preselectedList: preselectedList
            )
        }
        .sheet(isPresented: $showingNewList) {
            NewListView(trip: trip, listType: listType, user: selectedUser)
        }
    }
}

private struct PackingListContent: View {
    @Environment(\.modelContext) private var modelContext
    let trip: Trip
    let listType: ListType
    let selectedUser: User?
    let showingPackedItems: Bool
    let viewStyle: UnifiedPackingView.ViewStyle
    let sortOrder: PackingListSortOrder
    let showUserPill: Bool
    @Binding var preselectedList: PackingList?
    @Binding var showingAddItem: Bool
    
    var body: some View {
        Group {
            if viewStyle == .unified {
                UnifiedListContentView(
                    trip: trip,
                    listType: listType,
                    selectedUser: selectedUser,
                    showingPackedItems: showingPackedItems,
                    showUserPill: showUserPill
                )
            } else {
                SeparatedListContentView(
                    trip: trip,
                    listType: listType,
                    selectedUser: selectedUser,
                    showingPackedItems: showingPackedItems,
                    sortOrder: sortOrder,
                    showUserPill: showUserPill,
                    preselectedList: $preselectedList,
                    showingAddItem: $showingAddItem
                )
            }
        }
    }
}

private struct UnifiedListContentView: View {
    @Environment(\.modelContext) private var modelContext
    let trip: Trip
    let listType: ListType
    let selectedUser: User?
    let showingPackedItems: Bool
    let showUserPill: Bool
    
    func getFilteredItems() -> [Item] {
        let lists = trip.getLists(for: selectedUser, ofType: listType)
        var allItems: [Item] = []
        for list in lists {
            if let items = list.items {
                allItems.append(contentsOf: items)
            }
        }
        let filteredItems = allItems.filter { item in
            showingPackedItems ? item.isPacked : !item.isPacked
        }
        return filteredItems.sorted { $0.name < $1.name }
    }
    
    var body: some View {
        Group {
            if getFilteredItems().isEmpty {
                ContentUnavailableView {
                    Label(
                        showingPackedItems ? "No packed items" : "Nothing to pack",
                        systemImage: "bag"
                    )
                } description: {
                    Text(showingPackedItems ?
                         "Items you pack will appear here" :
                            "Add items to your packing list to get started"
                    )
                }
            } else {
                List {
                    ForEach(getFilteredItems()) { item in
                        ItemRow(item: item, showUserPill: showUserPill)
                            .swipeActions(edge: .trailing) {
                                Button(role: .destructive) {
                                    withAnimation {
                                        if let list = item.list {
                                            list.removeItem(item)
                                        }
                                        modelContext.delete(item)
                                    }
                                } label: {
                                    Label("Delete", systemImage: "trash")
                                }
                            }
                    }
                }
                .listStyle(.plain)
            }
        }
    }
}

private struct SeparatedListContentView: View {
    let trip: Trip
    let listType: ListType
    let selectedUser: User?
    let showingPackedItems: Bool
    let sortOrder: PackingListSortOrder
    let showUserPill: Bool
    @Binding var preselectedList: PackingList?
    @Binding var showingAddItem: Bool
    
    var body: some View {
        List {
            let lists = PackingList.sorted(trip.getLists(for: selectedUser, ofType: listType), sortOrder: sortOrder)
            ForEach(lists) { list in
                PackingListSection(
                    list: list,
                    showingPackedItems: showingPackedItems,
                    showUserPill: showUserPill,
                    preselectedList: $preselectedList,
                    showingAddItem: $showingAddItem
                )
            }
        }
    }
}

private struct PackingListSection: View {
    @Environment(\.modelContext) private var modelContext
    let list: PackingList
    let showingPackedItems: Bool
    let showUserPill: Bool
    @Binding var preselectedList: PackingList?
    @Binding var showingAddItem: Bool
    
    var listItems: [Item] {
        list.items?.filter { showingPackedItems ? $0.isPacked : !$0.isPacked } ?? []
    }
    
    var body: some View {
        Section(
            header: ListHeader(list: list, showUserPill: showUserPill),
            footer: Button(action: {
                preselectedList = list
                showingAddItem = true
            }) {
                Label("Add item", systemImage: "plus")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .buttonStyle(.plain)
        ) {
            if listItems.isEmpty {
                Text("No items")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .listRowBackground(Color.clear)
            } else {
                ForEach(listItems) { item in
                    ItemRow(item: item, showUserPill: false)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                withAnimation {
                                    list.removeItem(item)
                                    modelContext.delete(item)
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

private struct MainMenuButton: View {
    @Binding var viewStyle: UnifiedPackingView.ViewStyle
    @Binding var selectedUser: User?
    @Binding var sortOrder: PackingListSortOrder
    let trip: Trip
    
    var body: some View {
        Menu {
            Picker("View style", selection: $viewStyle) {
                Label("Unified view", systemImage: "list.bullet")
                    .tag(UnifiedPackingView.ViewStyle.unified)
                Label("List view", systemImage: "folder")
                    .tag(UnifiedPackingView.ViewStyle.byList)
            }
            
            if selectedUser == nil {
                Menu("Filter by packer") {
                    Button("All packers") {
                        selectedUser = nil
                    }
                    
                    if let lists = trip.lists {
                        ForEach(Array(Set(lists.compactMap { $0.user })), id: \.id) { user in
                            Button(user.name) {
                                selectedUser = user
                            }
                        }
                    }
                }
            } else {
                Button("Clear filter") {
                    selectedUser = nil
                }
            }
            
            Picker("Sort", selection: $sortOrder) {
                ForEach(PackingListSortOrder.allCases, id: \.self) { order in
                    Text(order.name).tag(order)
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title2)
        }
    }
}

private struct AddItemButton: View {
    @Binding var showingAddItem: Bool
    
    var body: some View {
        Button(action: { showingAddItem = true }) {
            Label("Add item", systemImage: "plus.circle.fill")
                .font(.headline)
                .padding()
                .frame(maxWidth: .infinity)
                .background(.blue)
                .foregroundColor(.white)
                .clipShape(Capsule())
        }
        .padding()
    }
}

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    let item: Item
    let showUserPill: Bool
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { item.isPacked },
                set: { newValue in
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        item.isPacked = newValue
                    }
                }
            )) {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(item.name)
                        QuantityPill(count: item.count)
                    }
                    
                    HStack {
                        if showUserPill, let list = item.list, let user = list.user {
                            user.pillIcon
                        }
                        
                        Text(item.list?.name ?? "")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toggleStyle(CheckmarkToggleStyle())
        }
    }
}

struct QuantityPill: View {
    let count: Int
    
    var body: some View {
        if count > 1 {
            Text("×\(count)")
                .font(.caption2.weight(.semibold))
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.blue.opacity(0.1))
                .foregroundStyle(.blue)
                .clipShape(Capsule())
        }
    }
}

struct ListHeader: View {
    @Environment(\.modelContext) private var modelContext
    let list: PackingList
    let showUserPill: Bool
    @State private var showingDeleteConfirmation = false
    @State private var showingSaveAsTemplateConfirmation = false
    
    var body: some View {
        HStack {
            Text(list.name)
                .font(.headline)
            if let user = list.user, showUserPill {
                user.pillIcon
            }
            Spacer()
            Menu {
                Button {
                    showingSaveAsTemplateConfirmation = true
                } label: {
                    Label("Save as template", systemImage: "doc.badge.plus")
                        .textCase(nil)
                }
                
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete list", systemImage: "trash")
                        .textCase(nil)
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
        .confirmationDialog(
            "Delete list",
            isPresented: $showingDeleteConfirmation
        ) {
            Button("Delete '\(list.name)'", role: .destructive) {
                withAnimation {
                    PackingList.delete(list, from: modelContext)
                }
            }
            .textCase(nil)
        } message: {
            Text("Are you sure you want to delete '\(list.name)'? This action cannot be undone.")
                .textCase(nil)
        }
        .confirmationDialog(
            "Save as template",
            isPresented: $showingSaveAsTemplateConfirmation
        ) {
            Button("Save '\(list.name)' as template") {
                withAnimation {
                    let templateList = PackingList.copyAsTemplate(list)
                    modelContext.insert(templateList)
                }
            }
            .textCase(nil)
        } message: {
            Text("This will create a new template list based on '\(list.name)' that can be used for future trips.")
                .textCase(nil)
        }
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let trip: Trip
    let listType: ListType
    let selectedUser: User?
    let preselectedList: PackingList?
    
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var selectedList: PackingList?
    @FocusState private var isItemNameFocused: Bool
    
    var availableLists: [PackingList] {
        trip.getLists(for: selectedUser, ofType: listType)
    }
    
    init(trip: Trip, listType: ListType, selectedUser: User?, preselectedList: PackingList? = nil) {
        self.trip = trip
        self.listType = listType
        self.selectedUser = selectedUser
        self.preselectedList = preselectedList
        self._selectedList = State(initialValue: preselectedList)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack(spacing: 8) {
                    // Item Name Input
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Item name")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                            .padding(.leading, 8)
                        
                        TextField("Item name", text: $itemName)
                            .textFieldStyle(.plain)
                            .padding()
                            .frame(height: 52)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                            .focused($isItemNameFocused)
                    }
                    
                    if listType != .task {
                        // Compact Quantity Selector
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Quantity")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 8)
                            
                            HStack {
                                Button {
                                    if quantity > 1 {
                                        quantity -= 1
                                    }
                                } label: {
                                    Image(systemName: "minus.circle.fill")
                                        .imageScale(.large)
                                }
                                .foregroundStyle(quantity > 1 ? .blue : .gray)
                                
                                Text("\(quantity)")
                                    .font(.headline)
                                    .frame(minWidth: 32)
                                    .multilineTextAlignment(.center)
                                
                                Button {
                                    if quantity < 99 {
                                        quantity += 1
                                    }
                                } label: {
                                    Image(systemName: "plus.circle.fill")
                                        .imageScale(.large)
                                }
                                .foregroundStyle(.blue)
                            }
                            .padding()
                            .frame(height: 52)
                            .background(Color(.secondarySystemBackground))
                            .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                            .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                        }
                    }
                }
                
                // List Selector (only if no preselected list)
                if preselectedList == nil {
                    HStack {
                        Picker(selection: $selectedList) {
                            Group {
                                if selectedList == nil {
                                    Text("No list selected").tag(nil as PackingList?)
                                }
                                ForEach(availableLists) { list in
                                    HStack {
                                        Text(list.name)
                                        if let user = list.user {
                                            user.pillIcon
                                        }
                                    }
                                    .tag(Optional(list))
                                }
                            }
                        } label: {
                            Text("Add to list")
                        }
                        .pickerStyle(.navigationLink)
                        .padding()
                        .frame(height: 52)
                        .background(Color(.secondarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                        .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
                    }
                }
                
                Spacer()
                
                // Add Button
                Button {
                    let targetList = preselectedList ?? selectedList
                    if let list = targetList {
                        Item.create(
                            for: list,
                            in: modelContext,
                            category: nil,
                            name: itemName,
                            count: quantity,
                            isPacked: false
                        )
                        dismiss()
                    }
                } label: {
                    Text("Add item")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(!itemName.isEmpty && (preselectedList != nil || selectedList != nil) ? .blue : .gray)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(itemName.isEmpty || (preselectedList == nil && selectedList == nil))
            }
            .padding()
            .background(Color(.systemGray6))
            .navigationTitle("Add item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
            }
        }
        .presentationDetents([.height(preselectedList == nil ? 300 : 220)])
        .onAppear {
            isItemNameFocused = true
            if selectedList == nil && availableLists.count == 1 {
                selectedList = availableLists.first
            }
        }
    }
}

struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                configuration.isOn.toggle()
            }
        }) {
            HStack {
                Image(systemName: configuration.isOn ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(configuration.isOn ? .blue : .gray)
                    .imageScale(.large)
                
                configuration.label
            }
        }
        .buttonStyle(.plain)
    }
}

struct NewListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let trip: Trip
    let listType: ListType
    let user: User?
    
    @State private var listName = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("List Name", text: $listName)
            }
            .navigationTitle("New List")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        PackingList.save(
                            nil,
                            name: listName,
                            type: listType,
                            template: false,
                            countAsDays: false,
                            user: user ?? User(name: "Default"),
                            in: modelContext,
                            for: trip
                        )
                        dismiss()
                    }
                    .disabled(listName.isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
