//
//  PackingListApplyDefaultView.swift
//  PackingHelper
//
//  Created by Todd Louison on 11/14/23.
//

import SwiftData
import SwiftUI

struct PackingListApplyDefaultView: View {
    @Environment(\.dismiss) private var dismiss
    
    let trip: Trip
    
    @State private var selectedUser: User?
    @State private var selectedLists: [PackingList] = []
    
    private var canSave: Bool {
        !selectedLists.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            List {
                // User Selection Section
                Section {
                    UserSelectionRow(selectedUser: $selectedUser)
                        .onChange(of: selectedUser) {
                            // Clear selection when user changes
                            selectedLists.removeAll()
                        }
                } header: {
                    Text("Select Packer")
                } footer: {
                    Text(selectedUser == nil ?
                         "Lists will be applied to the packer who created it" :
                         "Lists will be applied to \(selectedUser?.name ?? "")")
                }
                
                // List Selection Section
                Section {
                    NavigationLink {
                        ListSelectionView(
                            selectedLists: $selectedLists,
                            user: selectedUser,
                            trip: trip
                        )
                    } label: {
                        HStack {
                            Label("Select Lists", systemImage: "checklist")
                            Spacer()
                            Text("\(selectedLists.count) selected")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    if !selectedLists.isEmpty {
                        SelectedListsView(lists: selectedLists)
                    }
                } header: {
                    Text("Packing Lists")
                }
                
                // Already Applied Lists Section
                if !trip.alreadyUsedTemplates.isEmpty {
                    Section {
                        AppliedListsView(lists: trip.alreadyUsedTemplates)
                    } header: {
                        Text("Already Applied")
                    } footer: {
                        Text("These lists have already been applied and cannot be selected again")
                    }
                }
            }
            .navigationTitle("Apply Default Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        save()
                        dismiss()
                    }
                    .disabled(!canSave)
                }
            }
        }
    }
    
    private func save() {
        trip.applyDefaultLists(to: selectedUser, lists: selectedLists)
    }
}

// MARK: - Supporting Views

struct UserSelectionRow: View {
    @Binding var selectedUser: User?
    
    var body: some View {
        HStack {
            UserPickerView(selectedUser: $selectedUser, style: .inline)
        }
        .contentShape(Rectangle())
    }
}

struct SelectedListsView: View {
    let lists: [PackingList]
    
    var body: some View {
        ForEach(lists) { list in
            HStack {
                Label(list.name, systemImage: "suitcase")
                Spacer()
                Text("\(list.items?.count ?? 0) items")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

struct AppliedListsView: View {
    let lists: [PackingList]
    
    var body: some View {
        ForEach(lists) { list in
            HStack {
                Label(list.name, systemImage: "suitcase.fill")
                    .foregroundStyle(.secondary)
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)
            }
        }
    }
}

struct ListSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Binding var selectedLists: [PackingList]
    let user: User?
    let trip: Trip
    
    @Query(
        filter: #Predicate<PackingList> { $0.template == true },
        sort: [SortDescriptor(\.name)],
        animation: .snappy
    )
    private var defaultPackingLists: [PackingList]
    
    @State private var searchText = ""
    @State private var selectedListType: ListType?
    @State private var showingFilters = false
    
    private var filteredLists: [PackingList] {
        defaultPackingLists
            .filter { list in
                // Exclude already applied templates
                !trip.alreadyUsedTemplates.contains(list) &&
                // Apply user filter if specified
                (user == nil || list.user == user) &&
                // Apply type filter
                (selectedListType == nil || list.type == selectedListType) &&
                // Apply search filter
                (searchText.isEmpty || list.name.localizedCaseInsensitiveContains(searchText))
            }
    }
    
    private var hasActiveFilters: Bool {
        selectedListType != nil || !searchText.isEmpty
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showingFilters {
                    PackingListFilterSection(
                        searchText: $searchText,
                        selectedListType: $selectedListType,
                        selectedUser: .constant(user), // Fixed user for selection view
                        users: [],
                        showUserFilter: false,
                        hasActiveFilters: hasActiveFilters,
                        onClearFilters: clearFilters
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                if filteredLists.isEmpty {
                    PackingListEmptyStateView(
                        hasFilters: hasActiveFilters,
                        message: hasActiveFilters ?
                            "Try adjusting your filters" :
                            "No lists available to select",
                        actionButtonTitle: hasActiveFilters ?
                            "Clear All Filters" : "Done",
                        onAction: hasActiveFilters ?
                            clearFilters : { dismiss() }
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        selectablePackingListsGrid
                            .padding(.top)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Select Lists")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            showingFilters.toggle()
                        }
                    } label: {
                        Image(systemName: "line.3.horizontal.decrease.circle\(hasActiveFilters ? ".fill" : "")")
                            .fontWeight(.semibold)
                            .foregroundStyle(hasActiveFilters ? .accent : .primary)
                    }
                }
                
                ToolbarItem(placement: .bottomBar) {
                    selectionSummary
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var selectablePackingListsGrid: some View {
        LazyVStack(spacing: 8) {
            ForEach(filteredLists) { list in
                SelectablePackingListCard(
                    list: list,
                    isSelected: selectedLists.contains(list)
                ) {
                    toggleSelection(for: list)
                }
            }
        }
        .padding(.horizontal)
    }
    
    private var selectionSummary: some View {
        HStack {
            if selectedLists.isEmpty {
                Text("No lists selected")
                    .foregroundStyle(.secondary)
            } else {
                Text("\(selectedLists.count) list\(selectedLists.count == 1 ? "" : "s") selected")
                    .foregroundStyle(.secondary)
                
                Spacer()
                
                Button("Clear All") {
                    withAnimation {
                        selectedLists.removeAll()
                    }
                }
                .foregroundStyle(.red)
            }
        }
        .padding(.horizontal)
    }
    
    private func toggleSelection(for list: PackingList) {
        withAnimation {
            if selectedLists.contains(list) {
                selectedLists.removeAll { $0.id == list.id }
            } else {
                selectedLists.append(list)
            }
        }
    }
    
    private func clearFilters() {
        withAnimation {
            searchText = ""
            selectedListType = nil
        }
    }
}

struct SelectablePackingListCard: View {
    let list: PackingList
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // Left side: Name and selection indicator
                HStack(spacing: 8) {
                    Text(list.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }
                
                Spacer()
                
                // Right side: Count and type icon
                HStack(spacing: 8) {
                    HStack(spacing: 4) {
                        Text("\(list.totalItems)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            
                        Image(systemName: list.icon)
                            .foregroundColor(.accentColor)
                            .font(.subheadline)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
        .buttonStyle(.plain)
    }
}
