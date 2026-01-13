//
//  ItemRowViews.swift
//  PackingHelper
//
//  Created by Todd Louison on 9/17/25.
//

import SwiftUI
import SwiftData

struct NewItemRow: View {
    private enum FocusedField {
        case itemName
    }
    
    @Binding var itemName: String
    @Binding var itemCount: Int
    @Binding var itemUser: User?
    @Binding var itemList: PackingList?
    
    let listOptions: [PackingList]
    let showUserPicker: Bool
    
    @FocusState private var focusedField: FocusedField?
    let onCommit: () -> Void
    let onCancel: () -> Void
    
    var visibleLists: [PackingList] {
        listOptions.filter{ $0.user == itemUser }
    }
    
    var showListSelector: Bool {
        listOptions.count > 1
    }
    
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 12) {
                TextField("Item name", text: $itemName)
                    .focused($focusedField, equals: .itemName)
                    .onSubmit(onCommit)
                
                Stepper(value: $itemCount, in: 1...99) {
                    Text("\(itemCount)")
                        .foregroundColor(.secondary)
                        .frame(minWidth: 30)
                }
                
                Button(action: onCommit) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title3)
                }
                .opacity(itemName.isEmpty ? 0.3 : 1.0)
                .disabled(itemName.isEmpty)
            }
            
            if showListSelector || showUserPicker {
                HStack {
                    if showListSelector {
                        Picker("Packing List", selection: $itemList) {
                            ForEach(visibleLists, id: \.id) { list in
                                Text(list.name)
                                    .tag(list)
                            }
                        }
                        .onChange(of: itemUser) {
                            itemList = visibleLists.first
                        }
                    }
                    
                    
                    Spacer()
                    
                    if showUserPicker {
                        UserPickerView(selectedUser: $itemUser, style: .menu, allowAll: false)
                    }
                }
            }
        }
        .padding()
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.05), radius: 3, y: 2)
        .onAppear {
            focusedField = .itemName
        }
    }
}


struct EditableItemRow: View {
    let item: Item
    let mode: UnifiedPackingListMode
    let onCommit: (String, Int) -> Void
    let onCancel: () -> Void
    
    @State private var editName: String
    @State private var editCount: Int
    @FocusState private var isFocused: Bool
    
    init(item: Item, mode: UnifiedPackingListMode, onCommit: @escaping (String, Int) -> Void, onCancel: @escaping () -> Void) {
        self.item = item
        self.mode = mode
        self.onCommit = onCommit
        self.onCancel = onCancel
        self._editName = State(initialValue: item.name)
        self._editCount = State(initialValue: item.count)
    }
    
    var body: some View {
        HStack(spacing: 12) {
            if mode != .templating {
                Image(systemName: item.isPacked ? "checkmark.square.fill" : "square")
                    .font(.title3)
                    .foregroundColor(item.isPacked ? .blue : .gray.opacity(0.5))
            }
            
            TextField("Item name", text: $editName)
                .focused($isFocused)
                .onSubmit {
                    onCommit(editName, editCount)
                }
            
            Stepper(value: $editCount, in: 1...99) {
                Text("\(editCount)")
                    .foregroundColor(.secondary)
                    .frame(minWidth: 30)
            }
            
            Button(action: {
                onCommit(editName, editCount)
            }) {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title3)
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(Color(UIColor.secondarySystemGroupedBackground))
        .cornerRadius(10)
        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
        .onAppear {
            isFocused = true
        }
    }
}

struct UnifiedItemRow: View {
    let item: Item
    let mode: UnifiedPackingListMode
    let onTogglePacked: () -> Void
    let onEdit: () -> Void
    let onDelete: () -> Void

    @State private var offset: CGFloat = 0
    private let maxOffset: CGFloat = -52  // Room for floating button + spacing
    private let snapThreshold: CGFloat = -30

    // Show swipe-to-delete for template items (always) or unpacked items (non-template)
    private var showSwipeDelete: Bool {
        mode == .templating || !item.isPacked
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

    var body: some View {
        ZStack(alignment: .trailing) {
            // Row content (slides left when swiped)
            HStack(spacing: 12) {
                if mode != .templating {
                    Image(systemName: item.isPacked ? "checkmark.square.fill" : "square")
                        .font(.title3)
                        .foregroundColor(item.isPacked ? .blue : .gray.opacity(0.5))
                        .onTapGesture(perform: onTogglePacked)
                }

                Text(item.name)
                    .strikethrough(item.isPacked)
                    .foregroundColor(item.isPacked ? .gray : .primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture(perform: onEdit)

                if item.count > 1 {
                    Text("\(item.count)")
                        .font(.caption)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(Color(UIColor.secondarySystemGroupedBackground))
            .cornerRadius(10)
            .frame(maxWidth: .infinity, alignment: .leading)
            .offset(x: showSwipeDelete ? offset : 0)
            .gesture(
                showSwipeDelete ? DragGesture(minimumDistance: 20)
                    .onChanged { value in
                        if value.translation.width < 0 {
                            // Follow the user's finger - no clamping during drag
                            offset = value.translation.width
                        } else if offset < 0 {
                            // Allow swiping right to close
                            offset = min(0, offset + value.translation.width)
                        }
                    }
                    .onEnded { value in
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                            offset = offset < snapThreshold ? maxOffset : 0
                        }
                    } : nil
            )

            // Floating delete button (overlays on right side)
            if showSwipeDelete && offset < 0 {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = 0
                    }
                    // Delay delete slightly to allow animation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        onDelete()
                    }
                }) {
                    Image(systemName: "trash.fill")
                        .font(.body)
                        .foregroundColor(.white)
                        .frame(width: 44, height: 44)
                        .background(Color.red)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.2), radius: 4, y: 2)
                }
                .offset(x: 8)  // Position slightly outside the row edge
                .scaleEffect(deleteButtonScale)
                .opacity(deleteButtonOpacity)
            }
        }
        .contextMenu {
            Button(action: onEdit) {
                Label("Edit", systemImage: "pencil")
            }
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
        }
        .onChange(of: item.isPacked) { _, _ in
            // Reset offset when item is packed/unpacked
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                offset = 0
            }
        }
        .onChange(of: item.id) { _, _ in
            // Reset offset when item changes (e.g., after adding)
            offset = 0
        }
    }
}
