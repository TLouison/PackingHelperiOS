import SwiftUI
import SwiftData

enum SortOrder {
    case packingList(PackingListSortOrder)
    case item(ItemSortOrder)
    
    var packingListOrder: PackingListSortOrder? {
        if case let .packingList(order) = self {
            return order
        }
        return nil
    }
    
    var itemOrder: ItemSortOrder? {
        if case let .item(order) = self {
            return order
        }
        return nil
    }
}

struct UnifiedPackingView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var trip: Trip
    let listType: ListType
    
    @Binding var selectedUser: User?
    @State private var sortOrder: SortOrder = SortOrder.item(.byDate)
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
                
            QuickAddItemView(
                trip: trip,
                listType: listType,
                selectedUser: selectedUser,
                preselectedList: preselectedList
            )
            .padding()
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
    let sortOrder: SortOrder
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
                    sortOrder: sortOrder,
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
    let sortOrder: SortOrder
    let showUserPill: Bool
    
    func getFilteredItems() -> [Item] {
        let lists = PackingList.sorted(trip.getLists(for: selectedUser, ofType: listType), sortOrder: sortOrder.packingListOrder ?? .byDate)
        var allItems: [Item] = []
        for list in lists {
            if let items = list.items {
                allItems.append(contentsOf: items)
            }
        }
        let filteredItems = allItems.filter { item in
            showingPackedItems ? item.isPacked : !item.isPacked
        }
        return Item.sorted(filteredItems, sortOrder: sortOrder.itemOrder ?? .byDate)
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
    let sortOrder: SortOrder
    let showUserPill: Bool
    @Binding var preselectedList: PackingList?
    @Binding var showingAddItem: Bool
    
    var body: some View {
        List {
            let lists = PackingList.sorted(trip.getLists(for: selectedUser, ofType: listType), sortOrder: sortOrder.packingListOrder ?? .byDate)
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
            footer: QuickAddItemView(
                trip: list.trip!,
                listType: list.type,
                selectedUser: list.user,
                preselectedList: list
            )
            .listRowInsets(EdgeInsets())
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
    // Technically this is not good because we also have ItemSortOrder which
    // has the same values, but the ItemSortOrder has additional options so
    // I chose the one that is a subset
    @Binding var sortOrder: SortOrder
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
            
            if (viewStyle == .unified) {
                if case let .item(order) = sortOrder {
                    SortOrderPicker(selection: Binding(
                        get: { order },
                        set: { sortOrder = .item($0) }
                    ))
                }
            } else {
                if case let .packingList(order) = sortOrder {
                    SortOrderPicker(selection: Binding(
                        get: { order },
                        set: { sortOrder = .packingList($0) }
                    ))
                }
            }
        } label: {
            Image(systemName: "line.3.horizontal.decrease.circle")
                .font(.title2)
        }
        .onChange(of: viewStyle) {
            if viewStyle == .unified {
                sortOrder = SortOrder.item(.byDate)
            } else {
                sortOrder = SortOrder.packingList(.byDate)
            }
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

struct QuickAddItemView: View {
    @Environment(\.modelContext) private var modelContext
    
    let trip: Trip
    let listType: ListType
    let selectedUser: User?
    let preselectedList: PackingList?
    
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var selectedList: PackingList?
    @State private var showingListPicker = false
    @FocusState private var isItemNameFocused: Bool
    
    @Query private var availableLists: [PackingList]
    
    init(trip: Trip, listType: ListType, selectedUser: User?, preselectedList: PackingList?) {
        self.trip = trip
        self.listType = listType
        self.selectedUser = selectedUser
        self.preselectedList = preselectedList
        
        let tripUUID = trip.uuid
        let listFilter = #Predicate<PackingList> { list in
            list.template == false && list.trip?.uuid == tripUUID
        }
        
        _availableLists = Query(
            filter: listFilter,
            sort: [SortDescriptor(\PackingList.name, order: .forward)],
            animation: .snappy
        )
    }
    
    var filteredLists: [PackingList] {
        let lists = availableLists.filter { $0.type == listType }
        if let selectedUser = selectedUser {
            return lists.filter { $0.user == selectedUser }
        }
        return lists
    }
    
    var targetList: PackingList? {
        preselectedList ?? selectedList ?? (filteredLists.count == 1 ? filteredLists.first : nil)
    }
    
    var needsListSelection: Bool {
        preselectedList == nil && filteredLists.count > 1 && selectedList == nil
    }
    
    var body: some View {
        VStack(spacing: 8) {
            if needsListSelection {
                HStack {
                    Button(action: { showingListPicker = true }) {
                        HStack {
                            Text(selectedList?.name ?? "Select list")
                                .foregroundStyle(selectedList == nil ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.secondary)
                                .font(.caption)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                    .buttonStyle(.plain)
                    
                    if listType != .task {
                        HStack(spacing: 2) {
                            Button {
                                if quantity > 1 { quantity -= 1 }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundStyle(quantity > 1 ? .blue : .gray)
                            }
                            .disabled(quantity <= 1)
                            
                            Text("\(quantity)")
                                .font(.subheadline.weight(.medium))
                                .frame(minWidth: 20)
                            
                            Button {
                                if quantity < 99 { quantity += 1 }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .foregroundStyle(.blue)
                            }
                            .disabled(quantity >= 99)
                        }
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)
                        .background(Color(.tertiarySystemBackground))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                }
            }
            
            HStack(spacing: 8) {
                TextField("Add item...", text: $itemName)
                    .textFieldStyle(.plain)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.tertiarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .focused($isItemNameFocused)
                    .submitLabel(.done)
                    .onSubmit {
                        addItem()
                    }
                
                
                
                Button(action: addItem) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                        .foregroundStyle(canAddItem ? .blue : .gray)
                }
                .disabled(!canAddItem)
                .padding(8)
                .background(RoundedRectangle(cornerRadius: 12).fill(Color(.tertiarySystemBackground)))
            }
        }
        .onAppear {
            if filteredLists.count == 1 {
                selectedList = filteredLists.first
            }
        }
        .sheet(isPresented: $showingListPicker) {
            NavigationStack {
                List(filteredLists, id: \.id) { list in
                    Button(action: {
                        selectedList = list
                        showingListPicker = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            isItemNameFocused = true
                        }
                    }) {
                        HStack {
                            Text(list.name)
                            Spacer()
                            if selectedList == list {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(.blue)
                            }
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
                .navigationTitle("Select List")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") {
                            showingListPicker = false
                        }
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
    
    var canAddItem: Bool {
        !itemName.isEmpty
    }
    
    func addItem() {
        guard let list = targetList, !itemName.isEmpty else { return }
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            Item.create(
                for: list,
                in: modelContext,
                category: nil,
                name: itemName,
                count: quantity,
                isPacked: false
            )
            
            itemName = ""
            quantity = 1
            isItemNameFocused = true
        }
    }
}

