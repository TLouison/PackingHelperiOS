//
//  SortOrderManager.swift
//  PackingHelper
//
//  Manages sort order for items and lists during drag-and-drop
//

import Foundation
import SwiftData

class SortOrderManager {

    // MARK: - Item Order Management

    /// Calculate next sort order for a new item in a list
    static func nextSortOrder(for list: PackingList) -> Int {
        let maxOrder = list.items?.map { $0.sortOrder }.max() ?? -1
        return maxOrder + 1
    }

    /// Calculate next unified sort order for a new item
    static func nextUnifiedSortOrder(in lists: [PackingList]) -> Int {
        let allItems = lists.flatMap { $0.items ?? [] }
        let maxOrder = allItems.map { $0.unifiedSortOrder }.max() ?? -1
        return maxOrder + 1
    }

    /// Reorder items within a list after a drag operation
    static func reorderItems(in list: PackingList, moving item: Item, to newIndex: Int) {
        var items = list.incompleteItems.sorted { $0.sortOrder < $1.sortOrder }

        // Find current index before removing
        guard let currentIndex = items.firstIndex(where: { $0.persistentModelID == item.persistentModelID }) else {
            return
        }

        // Adjust newIndex if moving forward (accounts for removal shifting indices)
        let adjustedIndex = currentIndex < newIndex ? newIndex - 1 : newIndex

        // Remove item from current position
        items.removeAll { $0.persistentModelID == item.persistentModelID }

        // Insert at new position
        let clampedIndex = min(max(0, adjustedIndex), items.count)
        items.insert(item, at: clampedIndex)

        // Reassign sort orders
        for (index, currentItem) in items.enumerated() {
            currentItem.sortOrder = index
        }
    }

    /// Move item to a different list
    static func moveItem(_ item: Item, to targetList: PackingList, at index: Int) {
        // Remove from source list
        item.list?.removeItem(item)

        // Add to target list
        targetList.addItem(item)
        item.list = targetList

        // Reorder in target list
        reorderItems(in: targetList, moving: item, to: index)
    }

    /// Reorder items in unified view (across all lists)
    static func reorderUnifiedItems(in lists: [PackingList], moving item: Item, to newIndex: Int) {
        var allUnpackedItems = lists
            .flatMap { $0.incompleteItems }
            .sorted { $0.unifiedSortOrder < $1.unifiedSortOrder }

        // Find current index before removing
        guard let currentIndex = allUnpackedItems.firstIndex(where: { $0.persistentModelID == item.persistentModelID }) else {
            return
        }

        // Adjust newIndex if moving forward (accounts for removal shifting indices)
        let adjustedIndex = currentIndex < newIndex ? newIndex - 1 : newIndex

        // Remove and reinsert
        allUnpackedItems.removeAll { $0.persistentModelID == item.persistentModelID }
        let clampedIndex = min(max(0, adjustedIndex), allUnpackedItems.count)
        allUnpackedItems.insert(item, at: clampedIndex)

        // Reassign unified sort orders
        for (index, currentItem) in allUnpackedItems.enumerated() {
            currentItem.unifiedSortOrder = index
        }
    }

    // MARK: - PackingList Order Management

    /// Calculate next sort order for a new list
    static func nextListSortOrder(in lists: [PackingList]) -> Int {
        let maxOrder = lists.map { $0.sortOrder }.max() ?? -1
        return maxOrder + 1
    }

    /// Reorder sections (PackingLists) in sectioned view
    static func reorderLists(_ lists: inout [PackingList], moving list: PackingList, to newIndex: Int) {
        lists.removeAll { $0.persistentModelID == list.persistentModelID }
        let clampedIndex = min(max(0, newIndex), lists.count)
        lists.insert(list, at: clampedIndex)

        for (index, currentList) in lists.enumerated() {
            currentList.sortOrder = index
        }
    }
}
