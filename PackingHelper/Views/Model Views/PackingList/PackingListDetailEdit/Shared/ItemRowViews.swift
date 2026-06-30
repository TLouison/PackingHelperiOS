//
//  ItemRowViews.swift
//  PackingHelper
//
//  Created by Todd Louison on 9/17/25.
//

import SwiftData
import SwiftUI

struct NewItemRow: View {
    @Binding var itemName: String
    @Binding var itemCount: Int
    @Binding var isFocused: Bool

    let onSubmitReturn: () -> Void

    @State private var countingDown = false

    var body: some View {
        HStack(alignment: .center) {
            PersistentTextField(
                text: $itemName,
                isFocused: $isFocused,
                placeholder: "Item name",
                onSubmit: onSubmitReturn
            )

            Spacer()

            HStack(spacing: 0) {
                Button {
                    if itemCount > 1 {
                        countingDown = true
                        withAnimation(.snappy) { itemCount -= 1 }
                    }
                } label: {
                    Image(systemName: "minus")
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Decrease count")
                Text("\(itemCount)")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
                    .frame(minWidth: 24, alignment: .center)
                    .contentTransition(.numericText(countsDown: countingDown))
                Button {
                    if itemCount < 99 {
                        countingDown = false
                        withAnimation(.snappy) { itemCount += 1 }
                    }
                } label: {
                    Image(systemName: "plus")
                        .frame(width: 32, height: 32)
                }
                .accessibilityLabel("Increase count")
            }
            .buttonStyle(.borderless)
        }
    }
}

struct EditableItemRow: View {
    let item: Item
    let isTemplating: Bool
    let onCommit: (String, Int) -> Void
    let onCancel: () -> Void

    @State private var editName: String
    @State private var editCount: Int
    @FocusState private var isFocused: Bool

    init(
        item: Item,
        isTemplating: Bool,
        onCommit: @escaping (String, Int) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.item = item
        self.isTemplating = isTemplating
        self.onCommit = onCommit
        self.onCancel = onCancel
        self._editName = State(initialValue: item.name)
        self._editCount = State(initialValue: item.count)
    }

    var body: some View {
        HStack(alignment: .center) {
            if !isTemplating {
                Image(
                    systemName: item.isPacked
                        ? "checkmark.circle.fill" : "circle"
                )
                .font(.title2)
                .foregroundStyle(item.isPacked ? .blue : .gray.opacity(0.5))
                .padding(.trailing, 12)
            }

            TextField("Item name", text: $editName)
                .focused($isFocused)
                .onSubmit {
                    onCommit(editName, editCount)
                }
            
            Spacer()

            Stepper(value: $editCount, in: 1...99) {
                Text("\(editCount)")
                    .foregroundStyle(.secondary)
                    .frame(minWidth: 30)
            }

            Button(action: {
                onCommit(editName, editCount)
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
                    .font(.title3)
            }
            .accessibilityLabel("Confirm")
            .padding(.leading, 12)
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(.rect(cornerRadius: 10))
        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
        .onAppear {
            isFocused = true
        }
    }
}

struct UnifiedItemRow: View {
    let item: Item
    let isTemplating: Bool
    let onTogglePacked: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    private let maxOffset: CGFloat = -52  // Room for floating button + spacing
    private let snapThreshold: CGFloat = -30

    // Show swipe-to-delete for template items (always) or unpacked items (non-template)
    private var showSwipeDelete: Bool {
        isTemplating || !item.isPacked
    }

    // Animate button scale from 0.5 to 1.0 as user swipes
    private var deleteButtonScale: CGFloat {
        guard showSwipeDelete else { return 0 }
        let progress = min(1, -offset / (-maxOffset))
        return 0.5 + (0.5 * progress)
    }

    // Fade button in from 0 to 1 as user swipes
    private var deleteButtonOpacity: CGFloat {
        guard showSwipeDelete else { return 0 }
        let progress = min(1, -offset / (-maxOffset))
        return progress
    }

    // Swipe progress from 0 to 1
    private var swipeProgress: CGFloat {
        guard showSwipeDelete else { return 0 }
        return min(1, -offset / (-maxOffset))
    }

    var body: some View {
        rowContent
            .padding(.vertical, 4)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.secondarySystemBackground).opacity(Double(swipeProgress * swipeProgress)))
                    .padding(.vertical, -3)
            }
            .offset(x: showSwipeDelete ? offset : 0)
            .gesture(
                showSwipeDelete
                    ? DragGesture(minimumDistance: 20)
                        .onChanged { value in
                            if value.translation.width < 0 {
                                offset = value.translation.width
                            } else if offset < 0 {
                                offset = min(0, offset + value.translation.width)
                            }
                        }
                        .onEnded { _ in
                            withAnimation(.packingSpring) {
                                offset = offset < snapThreshold ? maxOffset : 0
                            }
                        } : nil
            )
            .overlay(alignment: .trailing) {
                if showSwipeDelete && offset < 0 {
                    Button(action: {
                        withAnimation(.packingSpring) {
                            offset = 0
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            onDelete()
                        }
                    }) {
                        Image(systemName: "trash.fill")
                            .font(.body)
                            .foregroundStyle(.white)
                            .frame(width: 44, height: 44)
                            .background(Color.red)
                            .clipShape(Circle())
                            .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                    }
                    .offset(x: 8)
                    .scaleEffect(deleteButtonScale)
                    .opacity(deleteButtonOpacity)
                }
            }
        .onChange(of: item.isPacked) { _, _ in
            // Reset offset when item is packed/unpacked
            withAnimation(.packingSpring) {
                offset = 0
            }
        }
        .onChange(of: item.id) { _, _ in
            // Reset offset when item changes (e.g., after adding)
            offset = 0
        }
    }

    var rowContent: some View {
        HStack(spacing: 12) {
            if !isTemplating {
                Button(action: onTogglePacked) {
                    Image(
                        systemName: item.isPacked
                            ? "checkmark.circle.fill" : "circle"
                    )
                    .font(.title2)
                    .foregroundStyle(item.isPacked ? .blue : .gray.opacity(0.5))
                }
                .buttonStyle(.plain)
                .accessibilityLabel(item.isPacked ? "Mark as unpacked" : "Mark as packed")
            }

            Button(action: onEdit) {
                Text(item.name)
                    .font(.body)
                    .strikethrough(item.isPacked)
                    .foregroundStyle(item.isPacked ? .gray : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)

            if item.count > 1 {
                Text("\(item.count)")
                    .font(.caption)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.blue)
                    .clipShape(.rect(cornerRadius: 10))
            }
        }
    }
}

// MARK: - Packed Items Section

struct PackedItemsSection: View {
    let items: [Item]
    let onTogglePacked: (Item) -> Void
    let onDeleteItem: (Item) -> Void
    var horizontalPadding: CGFloat = 16

    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.packingSpring) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Text("PACKED ITEMS")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(items.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(items) { item in
                        UnifiedItemRow(
                            item: item,
                            isTemplating: false,
                            onTogglePacked: { onTogglePacked(item) },
                            onEdit: {},
                            onDelete: { onDeleteItem(item) }
                        )
                        .opacity(0.6)
                    }
                }
            }
        }
    }
}

// MARK: - Insertion Placeholder

struct InsertionPlaceholder: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(Color.accentColor)
                .frame(width: 6, height: 6)
            Rectangle()
                .fill(Color.accentColor)
                .frame(height: 2)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.accentColor.opacity(0.1))
        )
        .opacity(opacity)
        .padding(.horizontal, 16)
        .padding(.vertical, 2)
        .onAppear {
            withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                opacity = 1.0
            }
        }
    }
}
