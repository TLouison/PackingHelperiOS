//
//  DefaultPackingListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/20/23.
//

import SwiftUI
import SwiftData

// MARK: - Refactored DefaultPackingListView

struct DefaultPackingListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(
        filter: #Predicate<PackingList> { $0.template == true },
        sort: [SortDescriptor(\.name)],
        animation: .snappy
    )
    private var defaultPackingLists: [PackingList]
    
    @Query private var users: [User]
    
    @State private var selectedUser: User?
    @State private var searchText = ""
    @State private var selectedListType: ListType?
    @State private var showingAddSheet = false
    @State private var showingFilters = false
    
    private var filteredLists: [PackingList] {
        defaultPackingLists
            .filter { list in
                let userMatch = selectedUser == nil || list.user == selectedUser
                let typeMatch = selectedListType == nil || list.type == selectedListType
                let searchMatch = searchText.isEmpty ||
                    list.name.localizedCaseInsensitiveContains(searchText)
                return userMatch && typeMatch && searchMatch
            }
    }
    
    private var hasActiveFilters: Bool {
        selectedUser != nil || selectedListType != nil || !searchText.isEmpty
    }
    
    private var showUserPill: Bool {
        users.count > 1 && selectedUser == nil
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showingFilters {
                    PackingListFilterSection(
                        searchText: $searchText,
                        selectedListType: $selectedListType,
                        selectedUser: $selectedUser,
                        users: users,
                        showUserFilter: users.count > 1,
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
                            "Create your first packing list to get started",
                        actionButtonTitle: hasActiveFilters ?
                            "Clear All Filters" : "Create Template List",
                        onAction: hasActiveFilters ?
                            clearFilters : { showingAddSheet.toggle() }
                    )
                    .frame(maxHeight: .infinity)
                } else {
                    packingListsGrid
                }
            }
//            .background(Color(.systemGroupedBackground))
            .navigationTitle("Template Lists")
//            .toolbarBackground(.visible, for: .navigationBar)
//            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    HStack(spacing: 16) {
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                showingFilters.toggle()
                            }
                        } label: {
                            Image(systemName: "line.3.horizontal.decrease.circle\(hasActiveFilters ? ".fill" : "")")
                                .fontWeight(.semibold)
                                .foregroundStyle(hasActiveFilters ? .accent : .primary)
                        }
                        
                        Button {
                            showingAddSheet.toggle()
                        } label: {
                            Image(systemName: "plus")
                                .fontWeight(.semibold)
                        }
                    }
                }
            }
            .sheet(isPresented: $showingAddSheet) {
                PackingListEditView(isTemplate: true, isDeleted: .constant(false))
            }
        }
    }
    
    private var packingListsGrid: some View {
        ScrollView {
            LazyVStack(spacing: 20) {
                ForEach(users.sorted(by: { $0.created < $1.created}), id: \.id) { user in
                    PackingListListSection(user: user, lists: filteredLists, showHeader: showUserPill)
                }
            }
            .padding(.horizontal)
        }
        .padding(.top)
    }
    
    private func clearFilters() {
        withAnimation {
            searchText = ""
            selectedUser = nil
            selectedListType = nil
        }
    }
}

struct FilterChip: View {
    let isSelected: Bool
    let label: String
    let icon: Image
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 6) {
                icon
                    .foregroundColor(isSelected ? .white : .accentColor)
                
                Text(label)
                    .fontWeight(.medium)
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .padding(.horizontal, 10) // Reduced from 12
            .padding(.vertical, 6)    // Reduced from 8
            .background(isSelected ? Color.accentColor : Color(.secondarySystemGroupedBackground))
            .cornerRadius(8)
        }
    }
}

struct PackingListListSection: View {
    let user: User
    let lists: [PackingList]
    let showHeader: Bool
    
    init(user: User, lists: [PackingList], showHeader: Bool) {
        self.user = user
        self.lists = lists.filter { $0.user == user }
        self.showHeader = showHeader
    }
    
    var body: some View {
        if !lists.isEmpty {
            VStack(alignment: .leading) {
                if showHeader {
                    HStack {
                        user.pillFirstInitialIcon
                        Text(user.name).font(.title)
                    }
                }
                ForEach(lists) { list in
                    PackingListCard(list: list)
                }
            }
        }
    }
}

struct PackingListCard: View {
    let list: PackingList

    var body: some View {
        NavigationLink(destination: PackingListContainerView(packingList: list)) {
            HStack(spacing: 12) {
                // Left side: Name and user pill
                HStack(spacing: 8) {
                    Text(list.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
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
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal)
            .background(Color(.secondarySystemGroupedBackground))
            .cornerRadius(12)
        }
    }
}

