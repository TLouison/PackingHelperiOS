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

struct PackingListContainerView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    let context: PackingListContext
    let users: [User]?
    let listType: ListType
    let isDayOf: Bool
    let title: String?

    @State private var editingList: PackingList? = nil
    @State private var showingAddListSheet: Bool = false
    @State private var isApplyingDefaultPackingList: Bool = false
    @State private var isAddingNewItem: Bool = false
    @State private var selectedUser: User?
    @State private var isReorderingSections: Bool = false

    // Single list mode state
    @State private var isShowingListSettings: Bool = false
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
        listType: ListType,
        isDayOf: Bool,
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
        let filtered = lists.filter { list in
            let typeMatch = list.type == listType && list.isDayOf == isDayOf
            if let selectedUser = selectedUser {
                return list.user == selectedUser && typeMatch
            } else {
                return typeMatch
            }
        }
        return PackingList.sorted(filtered, sortOrder: .byDate)
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

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

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
                        switch viewMode {
                        case .unified:
                            UnifiedPackingListView(
                                trip: trip,
                                users: users,
                                listType: listType,
                                isDayOf: isDayOf,
                                title: title,
                                mode: unifiedMode,
                                isAddingNewItem: $isAddingNewItem,
                                editingList: $editingList,
                                showingAddListSheet: $showingAddListSheet,
                                isApplyingDefaultPackingList:
                                    $isApplyingDefaultPackingList,
                                selectedUser: $selectedUser
                            )
                        case .sectioned:
                            SectionedPackingListView(
                                users: users,
                                listType: listType,
                                isDayOf: isDayOf,
                                title: title,
                                trip: trip,
                                isAddingNewItem: $isAddingNewItem,
                                editingList: $editingList,
                                showingAddListSheet: $showingAddListSheet,
                                isApplyingDefaultPackingList:
                                    $isApplyingDefaultPackingList,
                                selectedUser: $selectedUser,
                                isReorderingSections: $isReorderingSections
                            )
                        }
                    }
                    // For single list context, always use unified view
                    else if context.isSingleList,
                        let singleList = context.singleList
                    {
                        UnifiedPackingListView(
                            lists: [singleList],
                            users: users,
                            listType: listType,
                            isDayOf: isDayOf,
                            title: title,
                            mode: unifiedMode,
                            isAddingNewItem: $isAddingNewItem
                        )
                    }
                }

                // Summary bar (conditional based on context)
                if showSummaryBar {
                    PackingSummaryBar(packingLists: filteredLists)
                }
            }
        }
        .navigationTitle(title ?? "Packing")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    if isReorderingSections {
                        // Done button replaces FAB during reorder mode
                        Button("Done") {
                            isReorderingSections = false
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        Group {
                            if isAddingNewItem {
                                Button(action: cancelAddingNewItem) {
                                    Image(systemName: "x.circle.fill")
                                        .resizable()
                                        .foregroundColor(.gray)
                                }
                                .frame(width: 60, height: 60)
                                .glassEffectIfAvailable()
                            } else {
                                Button(action: startAddingNewItem) {
                                    Image(systemName: "plus.circle.fill")
                                        .resizable()
                                        .foregroundColor(.blue)
                                }
                                .frame(width: 60, height: 60)
                                .glassEffectIfAvailable()
                            }
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, context.isSingleList ? 30 : 75)
            }
        }
        .sheet(item: $editingList) { list in
            if let trip = context.trip {
                PackingListEditView(
                    packingList: list,
                    trip: trip,
                    isDeleted: .constant(false)
                )
            }
        }
        .sheet(isPresented: $showingAddListSheet) {
            if let trip = context.trip {
                AddPackingListSheet(
                    trip: trip,
                    listType: listType,
                    isDayOf: isDayOf,
                    users: users,
                    onAdd: { _ in }
                )
                .presentationDetents([.height(300)])
            }
        }
        .sheet(isPresented: $isApplyingDefaultPackingList) {
            if let trip = context.trip {
                PackingListApplyDefaultView(trip: trip)
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
        .alert("List saved as default", isPresented: $isShowingSaveSuccessful) {
            Button("OK", role: .cancel) {}
        }
        .onChange(of: isDeleted) {
            dismiss()
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Trip context: Full menu with view toggle + add list
                if context.isTrip {
                    Menu {
                        if showViewModeToggle {
                            Button {
                                viewMode =
                                    viewMode == .unified ? .sectioned : .unified
                            } label: {
                                Label(
                                    viewMode == .unified
                                        ? "View by List" : "View Unified",
                                    systemImage: viewMode == .unified
                                        ? "list.bullet.indent" : "list.bullet"
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
                            Label(
                                "Apply Template List",
                                systemImage: "doc.on.doc"
                            )
                        }

                        if viewMode == .sectioned {
                            Divider()

                            Button {
                                isReorderingSections = true
                            } label: {
                                Label(
                                    "Reorder Sections",
                                    systemImage: "arrow.up.arrow.down"
                                )
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
                // Single list context: Save as default (non-templates) + settings gear
                else if let singleList = context.singleList {
                    if !singleList.template {
                        Menu {
                            Button("Save As Default") {
                                saveListAsDefault(singleList)
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                    }

                    Button {
                        isShowingListSettings.toggle()
                    } label: {
                        Image(systemName: "gear")
                    }
                }
            }
        }
    }

    private func startAddingNewItem() {
        withAnimation {
            isAddingNewItem = true
        }
    }

    private func cancelAddingNewItem() {
        withAnimation {
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
