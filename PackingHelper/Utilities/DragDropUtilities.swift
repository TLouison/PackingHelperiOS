//
//  DragDropUtilities.swift
//  PackingHelper
//
//  Utilities for drag-and-drop functionality
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers

// MARK: - Custom UTTypes

extension UTType {
    static let packingItem = UTType(exportedAs: "com.packinghelper.item")
    static let packingList = UTType(exportedAs: "com.packinghelper.list")
}

// MARK: - Item Transfer Data

/// Wrapper struct for transferring Item references during drag-and-drop
struct ItemTransferData: Codable, Transferable {
    let itemUUID: UUID  // Unique identifier for lookup
    let sourceListUUID: UUID?  // For cross-list moves

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .packingItem)
    }

    init(item: Item) {
        self.itemUUID = item.uuid
        self.sourceListUUID = item.list?.uuid
    }
}

// MARK: - PackingList Transfer Data

/// Wrapper struct for transferring PackingList references during drag-and-drop
struct PackingListTransferData: Codable, Transferable {
    let listUUID: UUID  // Unique identifier for lookup

    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .packingList)
    }

    init(list: PackingList) {
        self.listUUID = list.uuid
    }
}
