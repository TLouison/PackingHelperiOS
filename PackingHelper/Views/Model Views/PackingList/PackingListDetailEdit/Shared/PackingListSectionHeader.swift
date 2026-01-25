//
//  PackingListSectionHeader.swift
//  PackingHelper
//
//  Created by Claude on 1/11/26.
//

import SwiftUI
import SwiftData

struct PackingListSectionHeader: View {
    let packingList: PackingList
    @Binding var isExpanded: Bool
    let onAddItem: () -> Void
    let onEditList: () -> Void
    let onDeleteList: () -> Void
    let onSaveAsDefault: () -> Void
    var isReorderMode: Bool = false

    private var isEmpty: Bool {
        packingList.items?.isEmpty ?? true
    }

    var body: some View {
        HStack(spacing: 12) {
            if isReorderMode {
                // Drag handle
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.secondary)
            } else {
                // Collapse chevron
                Image(systemName: "chevron.down")
                    .font(.caption)
                    .rotationEffect(isExpanded ? .degrees(0) : .degrees(-90))
                    .contentTransition(.interpolate)
                    .foregroundStyle(.secondary)
            }

            // List name (always shown)
            Group {
                Text(packingList.name)
                    .font(.headline)
                    .bold()

                Spacer()
            }
            .onTapGesture {
                if !isReorderMode {
                    withAnimation {
                        isExpanded.toggle()
                    }
                }
            }

            // Mini progress gauge
            TripDetailPackingProgressView(
                val: Double(packingList.completeItems.count),
                total: Double(packingList.totalItems),
                image: packingList.icon
            )
            .scaleEffect(0.6)

            // Add button
            Button {
                onAddItem()
            } label: {
                Image(systemName: "plus.circle.fill")
                    .imageScale(.medium)
                    .foregroundStyle(.accent)
            }
            .buttonStyle(.plain)

            // Edit button
            Button {
                onEditList()
            } label: {
                Image(systemName: "pencil.circle.fill")
                    .imageScale(.medium)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.plain)
        }
        .contentShape(Rectangle())
        .contextMenu {
            if !isReorderMode {
                Button {
                    onEditList()
                } label: {
                    Label("Edit List", systemImage: "pencil")
                }

                if !packingList.template {
                    Button {
                        onSaveAsDefault()
                    } label: {
                        Label("Save As Default", systemImage: "square.and.arrow.down")
                    }
                }

                Button(role: .destructive) {
                    onDeleteList()
                } label: {
                    Label("Delete List", systemImage: "trash")
                }
            }
        }
    }
}
