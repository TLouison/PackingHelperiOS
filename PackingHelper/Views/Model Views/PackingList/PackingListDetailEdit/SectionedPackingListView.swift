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
import OSLog

struct SectionedPackingListView: View {
    @Environment(\.modelContext) private var modelContext

    let users: [User]?
    let lists: [PackingList]
    let title: String?
    let trip: Trip

    // Bindings from container
    @Binding var isAddingNewItem: Bool
    @Binding var newItemList: PackingList?
    @Binding var editingList: PackingList?
    @Binding var showingAddListSheet: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    @Binding var selectedUser: User?
    @Binding var isReorderingSections: Bool
    @Binding var scrollToPlaceholder: Bool

    // Local state
    @State private var collapsedSections: Set<String> = []
    @State private var expandedSectionsBeforeReorder: Set<String> = []
    @State private var editingItemId: PersistentIdentifier?
    @State private var draggedList: PackingList?

    @State private var isShowingSaveSuccessful: Bool = false
    @State private var listToDelete: PackingList?

    var hasMultiplePackers: Bool {
        guard let users = users else { return false }
        return users.count > 1
    }

    var sortedLists: [PackingList] {
        // Sort by custom order for manual reordering
        return PackingList.sorted(lists, sortOrder: .byCustomOrder)
    }

    var allPackedItems: [Item] {
        var packedItems: [Item] = []
        for list in lists {
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
        ScrollViewReader { proxy in
        ScrollView {
            VStack(spacing: 16) {
                // List sections with drag-and-drop reordering
                ForEach(Array(sortedLists.enumerated()), id: \.element.id) { index, list in
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
                            onDeleteList: { listToDelete = list },
                            onSaveAsDefault: { saveListAsDefault(list) },
                            onItemReorder: handleItemReorder,
                            onCrossListDrop: handleCrossListMove,
                            onAddItemToList: { targetList in
                                newItemList = targetList
                                withAnimation { isAddingNewItem = true }
                            },
                            isReorderMode: isReorderingSections,
                            isAddingNewItem: isAddingNewItem,
                            targetList: newItemList
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
                            .clipShape(.rect(cornerRadius: 12))
                        }
                        .onAppear {
                            // Track when dragging starts
                            if draggedList?.persistentModelID == list.persistentModelID {
                                draggedList = list
                            }
                        }

                        // Drop zone after each section (reorder mode only)
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

                    // Divider between sections (not in reorder mode, not after last)
                    if !isReorderingSections && index < sortedLists.count - 1 {
                        Rectangle()
                            .fill(Color.secondary.opacity(0.2))
                            .frame(height: 2)
                            .padding(.horizontal, 8)
                    }
                }

                // Global packed items section
                if !allPackedItems.isEmpty {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 2)
                        .padding(.horizontal)
                    PackedItemsSection(
                        items: allPackedItems,
                        onTogglePacked: togglePacked,
                        onDeleteItem: deleteItem
                    )
                }

                // Empty state
                if lists.allSatisfy({ ($0.items?.isEmpty ?? true) }) && !isAddingNewItem {
                    EmptyStateView()
                        .padding(.top, 60)
                }
            }
            .padding(.vertical)
            .padding(.horizontal, 8)
        }
        .onAppear {
            loadCollapseState()
        }
        .onChange(of: newItemList) { _, targetList in
            // Auto-expand the target section when it changes
            if let targetList {
                let id = String(targetList.persistentModelID.hashValue)
                if collapsedSections.contains(id) {
                    withAnimation { collapsedSections.remove(id) }
                }
                // Scroll to placeholder — delay to allow section expansion to render
                if isAddingNewItem {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        withAnimation {
                            proxy.scrollTo(
                                "insertionPlaceholder-\(targetList.persistentModelID.hashValue)",
                                anchor: .bottom
                            )
                        }
                    }
                }
            }
        }
        .onChange(of: isAddingNewItem) { _, isAdding in
            if isAdding, let targetList = newItemList {
                withAnimation {
                    proxy.scrollTo(
                        "insertionPlaceholder-\(targetList.persistentModelID.hashValue)",
                        anchor: .bottom
                    )
                }
            }
        }
        .onChange(of: isReorderingSections) { _, isReordering in
            if isReordering {
                enterReorderMode()
            } else {
                exitReorderMode()
            }
        }
        .onChange(of: scrollToPlaceholder) { _, shouldScroll in
            if shouldScroll, let targetList = newItemList {
                scrollToPlaceholder = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        proxy.scrollTo(
                            "insertionPlaceholder-\(targetList.persistentModelID.hashValue)",
                            anchor: .bottom
                        )
                    }
                }
            }
        }
        .alert("List saved as default", isPresented: $isShowingSaveSuccessful) {
            Button("OK", role: .cancel) {}
        }
        .alert(
            "Delete List",
            isPresented: Binding(get: { listToDelete != nil }, set: { if !$0 { listToDelete = nil } }),
            presenting: listToDelete
        ) { list in
            Button("Delete", role: .destructive) {
                deleteList(list)
                listToDelete = nil
            }
            Button("Cancel", role: .cancel) {
                listToDelete = nil
            }
        } message: { list in
            if list.appliedFromTemplate != nil {
                Text("This will delete \"\(list.name)\" from your trip. The template list it was applied from will not be deleted.")
            } else {
                Text("Are you sure you want to delete \"\(list.name)\"?")
            }
        }
        } // end ScrollViewReader
    }

    private func loadCollapseState() {
        collapsedSections = SectionCollapseStateManager.loadCollapsedSections(for: trip.persistentModelID)

        // Auto-collapse empty lists
        for list in lists where (list.items?.isEmpty ?? true) {
            let id = String(list.persistentModelID.hashValue)
            if !collapsedSections.contains(id) {
                collapsedSections.insert(id)
            }
        }
    }

    private func togglePacked(_ item: Item) {
        withAnimation(.packingSpring) {
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
        withAnimation(.packingSpring) {
            modelContext.delete(item)
        }
    }

    private func deleteList(_ list: PackingList) {
        guard !list.isDefault else { return }
        withAnimation(.packingSpring) {
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

    private func handleItemReorder(item: Item, in list: PackingList, to newIndex: Int) {
        withAnimation(.packingSpring) {
            AppLogger.views.debug("Reordering item \(item.name) to index \(newIndex)")
            SortOrderManager.reorderItems(in: list, moving: item, to: newIndex)
        }
    }

    private func handleCrossListMove(item: Item, to targetList: PackingList, at index: Int) {
        withAnimation(.packingSpring) {
            AppLogger.views.debug("Moving item \(item.name) to list \(targetList.name) at index \(index)")
            SortOrderManager.moveItem(item, to: targetList, at: index)
        }
    }

    private func handleSectionReorder(list: PackingList, to newIndex: Int) {
        withAnimation(.packingSpring) {
            AppLogger.views.debug("Reordering section \(list.name) to index \(newIndex)")
            var mutableLists = sortedLists
            SortOrderManager.reorderLists(&mutableLists, moving: list, to: newIndex)
        }
    }

    private func enterReorderMode() {
        // Save which sections are currently expanded
        expandedSectionsBeforeReorder = Set(sortedLists.compactMap { list in
            let id = String(list.persistentModelID.hashValue)
            return collapsedSections.contains(id) ? nil : id
        })
        // Collapse all sections
        withAnimation {
            for list in sortedLists {
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

