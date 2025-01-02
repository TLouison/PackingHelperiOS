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
    
    enum ViewStyle {
        case unified, byList
    }
    @State private var showingAddItem = false
    @State private var showingNewList = false
    
    var items: [GroupedPackingItem] {
        let lists = trip.getLists(for: selectedUser, ofType: listType)
        let allItems = lists.flatMap { list in
            (list.items ?? []).map { item in
                GroupedPackingItem(item: item, list: list)
            }
        }
        return allItems.filter { showingPackedItems ? $0.item.isPacked : !$0.item.isPacked }
            .sorted { $0.item.name < $1.item.name }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Top filter bar
            HStack {
                Picker("View", selection: $showingPackedItems) {
                    Text("To Pack").tag(false)
                    Text("Packed").tag(true)
                }
                .pickerStyle(.segmented)
                .padding(.horizontal)
                
                Spacer()
                
                Menu {
                    Picker("View Style", selection: $viewStyle) {
                        Label("Unified View", systemImage: "list.bullet").tag(ViewStyle.unified)
                        Label("List View", systemImage: "folder").tag(ViewStyle.byList)
                    }

                    Picker("Sort", selection: $sortOrder) {
                        ForEach(PackingListSortOrder.allCases, id: \.self) { order in
                            Text(order.name).tag(order)
                        }
                    }
                    
                    Button("New List") {
                        showingNewList = true
                    }
                    
                    if selectedUser == nil {
                        Menu("Filter by Packer") {
                            Button("All Packers") {
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
                        Button("Clear Filter") {
                            selectedUser = nil
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                        .font(.title2)
                }
                .padding(.horizontal)
            }
            .padding(.vertical, 8)
            .background(Color(.systemBackground))
            
            if items.isEmpty && viewStyle == .unified {
                ContentUnavailableView {
                    Label(
                        showingPackedItems ? "No Packed Items" : "Nothing to Pack",
                        systemImage: "bag"
                    )
                } description: {
                    Text(showingPackedItems ?
                        "Items you pack will appear here" :
                        "Add items to your packing list to get started"
                    )
                }
            } else {
                Group {
                    if viewStyle == .unified {
                        List {
                            ForEach(items) { groupedItem in
                                ItemRow(groupedItem: groupedItem)
                            }
                        }
                        .listStyle(.plain)
                    } else {
                        List {
                            let lists = trip.getLists(for: selectedUser, ofType: listType)
                            ForEach(lists) { list in
                                let listItems = list.items?.filter { showingPackedItems ? $0.isPacked : !$0.isPacked } ?? []
                                if !listItems.isEmpty {
                                    Section(header: ListHeader(list: list)) {
                                        ForEach(listItems) { item in
                                            ItemRow(groupedItem: GroupedPackingItem(item: item, list: list))
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle(listType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: { showingAddItem = true }) {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(trip: trip, listType: listType, selectedUser: selectedUser)
        }
        .sheet(isPresented: $showingNewList) {
            NewListView(trip: trip, listType: listType, user: selectedUser)
        }
    }
}

struct GroupedPackingItem: Identifiable {
    let item: Item
    let list: PackingList
    var id: String { "\(item.id)-\(list.id)" }
}

struct ItemRow: View {
    @Environment(\.modelContext) private var modelContext
    let groupedItem: GroupedPackingItem
    
    var body: some View {
        HStack {
            Toggle(isOn: Binding(
                get: { groupedItem.item.isPacked },
                set: { groupedItem.item.isPacked = $0 }
            )) {
                VStack(alignment: .leading) {
                    Text(groupedItem.item.name)
                    
                    HStack {
                        if groupedItem.item.count > 1 {
                            Text("Qty: \(groupedItem.item.count)")
                                .font(.caption)
                        }
                        
                        if let user = groupedItem.list.user {
                            user.pillIcon
                        }
                        
                        Text(groupedItem.list.name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .toggleStyle(CheckmarkToggleStyle())
        }
    }
}

struct AddItemView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let trip: Trip
    let listType: ListType
    let selectedUser: User?
    
    @State private var itemName = ""
    @State private var quantity = 1
    @State private var selectedList: PackingList?
    
    var availableLists: [PackingList] {
        trip.getLists(for: selectedUser, ofType: listType)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Item Name", text: $itemName)
                
                if listType != .task {
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                }
                
                Picker("Add to List", selection: $selectedList) {
                    Text("Select a List").tag(nil as PackingList?)
                    ForEach(availableLists, id: \.id) { list in
                        Text(list.name).tag(Optional(list))
                    }
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", action: dismiss.callAsFunction)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        if let list = selectedList {
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
                    }
                    .disabled(itemName.isEmpty || selectedList == nil)
                }
            }
        }
        .presentationDetents([.medium])
        .onAppear {
            if availableLists.count == 1 {
                selectedList = availableLists.first
            }
        }
    }
}

struct CheckmarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Configuration) -> some View {
        Button(action: { configuration.isOn.toggle() }) {
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

struct ListHeader: View {
    let list: PackingList
    
    var body: some View {
        HStack {
            Text(list.name)
                .font(.headline)
            if let user = list.user {
                user.pillIcon
            }
            Spacer()
        }
        .padding(.vertical, 4)
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
