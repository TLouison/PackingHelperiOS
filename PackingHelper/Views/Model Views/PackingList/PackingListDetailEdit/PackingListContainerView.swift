//
//  PackingListContainerView.swift
//  PackingHelper
//
//  A container view that manages switching between UnifiedPackingListView
//  and SectionedPackingListView, and provides shared toolbar functionality.
//
//  Created by Claude on 1/11/26.
//

import SwiftData
import SwiftUI

// MARK: - Container View

struct PackingListContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let context: PackingListContext
    let users: [User]?
    let listType: ListType?
    let isDayOf: Bool?
    let title: String?

    @State private var editingList: PackingList? = nil
    @State private var showingAddListSheet: Bool = false
    @State private var isApplyingDefaultPackingList: Bool = false
    @State private var isAddingNewItem: Bool = false
    @State private var selectedUser: User?
    @State private var isReorderingSections: Bool = false

    // Centralized add-item state
    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var newItemUser: User? = nil
    @State private var newItemList: PackingList? = nil
    @State private var newItemFieldFocused = false
    @State private var scrollToPlaceholder = false

    // Single list mode state
    @State private var isShowingListSettings: Bool = false
    @State private var isShowingTemplateInfo: Bool = false
    @State private var isShowingSaveSuccessful: Bool = false
    @State private var isDeleted: Bool = false

    @AppStorage("packingListViewMode") private var viewMode:
        PackingListViewMode = .unified

    // MARK: - Initializers

    /// Initialize with a single packing list (template or trip list)
    init(packingList: PackingList) {
        self.context = .singleList(packingList)
        self.users = packingList.user != nil ? [packingList.user!] : nil
        self.listType = packingList.type
        self.isDayOf = packingList.isDayOf
        self.title = packingList.name
    }

    /// Initialize with a trip (for backwards compatibility)
    init(
        trip: Trip,
        users: [User]?,
        listType: ListType?,
        isDayOf: Bool?,
        title: String?
    ) {
        self.context = .trip(trip)
        self.users = users
        self.listType = listType
        self.isDayOf = isDayOf
        self.title = title
    }

    // MARK: - Computed Properties

    private var lists: [PackingList] {
        if let trip = context.trip {
            return trip.lists ?? []
        } else if let singleList = context.singleList {
            return [singleList]
        }
        return []
    }

    private var hasMultiplePackers: Bool {
        guard let users = users else { return false }
        return users.count > 1
    }

    private var filteredLists: [PackingList] {
        if listType != nil && isDayOf != nil {
            let filtered = lists.filter { list in
                let typeMatch = list.type == listType && list.isDayOf == isDayOf
                if let selectedUser = selectedUser {
                    return list.user == selectedUser && typeMatch
                } else {
                    return typeMatch
                }
            }
            return filtered
        } else {
            return lists
        }
    }

    /// Determines the mode for UnifiedPackingListView based on context
    private var unifiedMode: UnifiedPackingListMode {
        if context.isTrip {
            return .unified
        } else if let singleList = context.singleList {
            return singleList.template ? .templating : .detail
        }
        return .unified
    }

    /// Whether to show the user selector
    private var showUserSelector: Bool {
        context.isTrip && hasMultiplePackers
    }

    /// Whether to show the summary bar
    private var showSummaryBar: Bool {
        if context.isTrip {
            return true
        } else if let singleList = context.singleList {
            return !singleList.template
        }
        return false
    }

    /// Whether to show the view mode toggle
    private var showViewModeToggle: Bool {
        context.isTrip
    }

    private var baseView: some View {
        ZStack {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()

            packingListView
        }
        .safeAreaInset(edge: .bottom) {
            if isAddingNewItem && !isReorderingSections {
                floatingInputBar
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if isReorderingSections {
                doneButton
            } else if !isAddingNewItem {
                fabButton
            }
        }
        .navigationTitle(title ?? "Packing")
        .navigationBarTitleDisplayMode(context.singleList?.template == true ? .large : .inline)
        .sheet(item: $editingList) { list in
            if let trip = context.trip {
                PackingListEditView(
                    packingList: list,
                    trip: trip,
                    isDeleted: .constant(false)
                )
                .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $showingAddListSheet) {
            if let trip = context.trip {
                PackingListEditView(
                    packingList: nil,
                    trip: trip,
                    forceListType: listType,
                    forceDayOf: isDayOf,
                    onListCreated: { newList in
                        newItemUser = newList.user
                        newItemList = newList
                    }, isDeleted: .constant(false)
                )
                .presentationDetents([.medium])
            }
        }
        .sheet(isPresented: $isApplyingDefaultPackingList) {
            if let trip = context.trip {
                PackingListApplyDefaultView(trip: trip, listType: listType, isDayOf: isDayOf)
            }
        }
        .sheet(isPresented: $isShowingListSettings) {
            if let singleList = context.singleList {
                PackingListEditView(
                    packingList: singleList,
                    isTemplate: singleList.template,
                    isDeleted: $isDeleted
                )
            }
        }
        .sheet(isPresented: $isShowingTemplateInfo) {
            if let singleList = context.singleList {
                TemplateListInfoView(list: singleList)
                    .presentationDetents([.fraction(0.65), .large])
            }
        }
    }

    var body: some View {
        baseView
        .alert("List saved as default", isPresented: $isShowingSaveSuccessful) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: isDeleted) {
            dismiss()
        }
        .onChange(of: newItemUser) {
            // Don't reset if current list already belongs to the new user (e.g., just created)
            if newItemList?.user != newItemUser {
                newItemList = visibleListsForNewItem.first
            }
        }
        .toolbar {
            containerToolbar
        }
        .onAppear {
            newItemUser = users?.first
            newItemList = filteredLists.first(where: { $0.isDefault }) ?? filteredLists.first
        }
    }

    // MARK: - Floating Input Bar

    private var visibleListsForNewItem: [PackingList] {
        filteredLists.filter { $0.user == newItemUser }
    }

    private var listPickerChips: some View {
        HStack(spacing: 8) {
            Menu {
                ForEach(visibleListsForNewItem, id: \.id) { list in
                    Button {
                        newItemList = list
                    } label: {
                        if list.id == newItemList?.id {
                            Label(list.name, systemImage: "checkmark")
                        } else {
                            Text(list.name)
                        }
                    }
                }
            } label: {
                HStack(spacing: 6) {
                    Image(systemName: "list.bullet")
                        .font(.caption)
                    Text(newItemList?.name ?? "Select List")
                        .fontWeight(.medium)
                    Image(systemName: "chevron.up.chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .opaqueGlassCapsule()
            }
            .disabled(visibleListsForNewItem.count <= 1)

            if hasMultiplePackers {
                UserPickerView(
                    selectedUser: $newItemUser,
                    style: .menu,
                    allowAll: false
                )
            }

            Spacer()
        }
        .padding(.horizontal)
    }

    private var floatingInputBar: some View {
        VStack(spacing: 8) {
            if context.isTrip {
                listPickerChips
            }

            NewItemRow(
                itemName: $newItemName,
                itemCount: $newItemCount,
                isFocused: $newItemFieldFocused,
                onSubmitReturn: addNewItemAndContinue
            )
            .opaqueRoundedBox()
            .shaded()
            .padding(.horizontal, 8)
        }
        .padding(.bottom, 8)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.3, anchor: .bottomTrailing).combined(with: .opacity),
            removal: .scale(scale: 0.3, anchor: .bottomTrailing).combined(with: .opacity)
        ))
    }

    // MARK: - FAB Button

    private var fabButton: some View {
        Button(action: startAddingNewItem) {
            Image(systemName: "plus.circle.fill")
                .resizable()
                .foregroundStyle(.blue)
        }
        .accessibilityLabel("Add Item")
        .frame(width: 60, height: 60)
        .glassEffectIfAvailable()
        .padding(.trailing, 16)
        .padding(.bottom, 16)
        .transition(.asymmetric(
            insertion: .scale(scale: 0.3, anchor: .bottomTrailing).combined(with: .opacity),
            removal: .scale(scale: 0.3, anchor: .bottomTrailing).combined(with: .opacity)
        ))
    }

    // MARK: - Done Button (Reorder Mode)

    private var doneButton: some View {
        Button("Done") {
            isReorderingSections = false
        }
        .buttonStyle(.borderedProminent)
        .controlSize(.large)
        .padding(.trailing, 16)
        .padding(.bottom, 16)
    }

    private var packingListView: some View {
        VStack(spacing: 0) {
            // User selector (trip context with multiple packers only)
            if showUserSelector {
                UserSelector(
                    users: users ?? [],
                    selectedUser: $selectedUser
                )
            }

            Group {
                // For trip context, allow view mode switching
                if context.isTrip, let trip = context.trip {
                    multiListView(trip: trip)
                }
                // For single list context, always use unified view
                else if context.isSingleList, let singleList = context.singleList
                {
                    singleListView(list: singleList)
                }
            }

            // Summary bar hidden when adding to prevent stacking with input bar
            if showSummaryBar && !isAddingNewItem {
                PackingSummaryBar(packingLists: filteredLists)
            }
        }
    }

    @ViewBuilder
    private func multiListView(trip: Trip) -> some View {
        switch viewMode {
        case .unified:
            UnifiedPackingListView(
                lists: filteredLists,
                users: users,
                title: title,
                mode: unifiedMode,
                newItemList: newItemList,
                isAddingNewItem: $isAddingNewItem,
                editingList: $editingList,
                showingAddListSheet: $showingAddListSheet,
                isApplyingDefaultPackingList: $isApplyingDefaultPackingList,
                selectedUser: $selectedUser,
                scrollToPlaceholder: $scrollToPlaceholder
            )
        case .sectioned:
            SectionedPackingListView(
                users: users,
                lists: filteredLists,
                title: title,
                trip: trip,
                isAddingNewItem: $isAddingNewItem,
                newItemList: $newItemList,
                editingList: $editingList,
                showingAddListSheet: $showingAddListSheet,
                isApplyingDefaultPackingList: $isApplyingDefaultPackingList,
                selectedUser: $selectedUser,
                isReorderingSections: $isReorderingSections,
                scrollToPlaceholder: $scrollToPlaceholder
            )
        }
    }

    private func singleListView(list: PackingList) -> some View {
        UnifiedPackingListView(
            lists: [list],
            users: users,
            title: title,
            mode: unifiedMode,
            newItemList: newItemList,
            isAddingNewItem: $isAddingNewItem,
            scrollToPlaceholder: $scrollToPlaceholder
        )
    }

    @ToolbarContentBuilder
    private var containerToolbar: some ToolbarContent {
        if isAddingNewItem {
            addingItemToolbar
        } else if context.isTrip {
            tripToolbar
        } else {
            singleListToolbar
        }
    }

    @ToolbarContentBuilder
    private var addingItemToolbar: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button { cancelAddingNewItem() } label: {
                Text("Cancel")
            }
        }
        ToolbarItem(placement: .confirmationAction) {
            Button { addNewItemAndClose() } label: {
                Image(systemName: "checkmark")
                    .fontWeight(.semibold)
            }
            .opacity(newItemName.isEmpty ? 0.3 : 1.0)
            .disabled(newItemName.isEmpty)
        }
    }

    @ToolbarContentBuilder
    private var tripToolbar: some ToolbarContent {
        ToolbarItem(placement: .topBarTrailing) {
            Menu {
                if showViewModeToggle {
                    Button {
                        viewMode = viewMode == .unified ? .sectioned : .unified
                    } label: {
                        Label(
                            viewMode == .unified ? "View by List" : "View Unified",
                            systemImage: viewMode == .unified ? "list.bullet.indent" : "list.bullet"
                        )
                    }
                    Divider()
                }

                Button {
                    showingAddListSheet.toggle()
                } label: {
                    Label("Create List", systemImage: "plus")
                }

                Button {
                    isApplyingDefaultPackingList.toggle()
                } label: {
                    Label("Apply Template List", systemImage: "doc.on.doc")
                }

                if viewMode == .sectioned {
                    Divider()
                    Button {
                        isReorderingSections = true
                    } label: {
                        Label("Reorder Sections", systemImage: "arrow.up.arrow.down")
                    }
                }
            } label: {
                Label("Options", systemImage: "ellipsis.circle")
            }
        }
    }

    @ToolbarContentBuilder
    private var singleListToolbar: some ToolbarContent {
        if let singleList = context.singleList {
            if !singleList.template && !singleList.isDefault {
                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        Button("Save As Default") {
                            saveListAsDefault(singleList)
                        }
                    } label: {
                        Label("Save As Default", systemImage: "square.and.arrow.up")
                    }
                }
            }
            if singleList.template {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingTemplateInfo.toggle()
                    } label: {
                        Label("List Info", systemImage: "info.circle")
                    }
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingListSettings.toggle()
                } label: {
                    Label("List Settings", systemImage: "gear")
                }
            }
        }
    }

    // MARK: - Add Item Actions

    private func startAddingNewItem() {
        newItemFieldFocused = true
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            isAddingNewItem = true
        }
    }

    private func cancelAddingNewItem() {
        newItemFieldFocused = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            newItemName = ""
            newItemCount = 1
            isAddingNewItem = false
        }
    }

    private func addNewItemAndContinue() {
        guard let list = newItemList else { return }
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }

        withAnimation(.packingSpring) {
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
        }

        scrollToPlaceholder = true
    }

    private func addNewItemAndClose() {
        if !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
           let list = newItemList
        {
            withAnimation(.packingSpring) {
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
            }
        }

        newItemFieldFocused = false
        withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
            newItemName = ""
            newItemCount = 1
            isAddingNewItem = false
        }
    }

    private func saveListAsDefault(_ list: PackingList) {
        withAnimation {
            let newDefaultList = PackingList.copyAsTemplate(list)
            modelContext.insert(newDefaultList)
            isShowingSaveSuccessful = true
        }
    }
}
