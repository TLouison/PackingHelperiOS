//
//  DefaultPackingListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/20/23.
//

import SwiftUI
import SwiftData

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
                    filterSection
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
                
                // Main content
                if filteredLists.isEmpty {
                    emptyStateView
                        .frame(maxHeight: .infinity)
                } else {
                    ScrollView {
                        packingListsGrid
                            .padding(.top)
                    }
                }
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Packing Lists")
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarBackground(Color(.systemGroupedBackground), for: .navigationBar)
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
    
    private var filterSection: some View {
        VStack(spacing: 12) {
            // Search bar always visible in filter section
            searchBar
            
            if users.count > 1 {
                userFilterSection
            }
            
            listTypeFilterSection
            
            if hasActiveFilters {
                Button {
                    withAnimation {
                        searchText = ""
                        selectedUser = nil
                        selectedListType = nil
                    }
                } label: {
                    Text("Clear All Filters")
                        .font(.subheadline)
                        .foregroundColor(.red)
                }
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 12)
        .background(Color(.secondarySystemGroupedBackground))
    }

    private var userFilterSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Filter by User")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        isSelected: selectedUser == nil,
                        label: "All Users",
                        icon: Image(systemName: "person.2"),
                        action: {
                            withAnimation {
                                selectedUser = nil
                            }
                        }
                    )
                    
                    ForEach(users) { user in
                        FilterChip(
                            isSelected: selectedUser == user,
                            label: user.name,
                            icon: Image(systemName: "person.circle"),
                            action: {
                                withAnimation {
                                    selectedUser = selectedUser == user ? nil : user
                                }
                            }
                        )
                    }
                }
            }
        }
    }
    
    private var listTypeFilterSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Filter by Type")
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    FilterChip(
                        isSelected: selectedListType == nil,
                        label: "All Types",
                        icon: Image(systemName: "square.grid.2x2"),
                        action: {
                            withAnimation {
                                selectedListType = nil
                            }
                        }
                    )
                    
                    ForEach(ListType.allCases, id: \.self) { type in
                        FilterChip(
                            isSelected: selectedListType == type,
                            label: type.rawValue,
                            icon: Image(systemName: type.icon),
                            action: {
                                withAnimation {
                                    selectedListType = selectedListType == type ? nil : type
                                }
                            }
                        )
                    }
                }
            }
        }
    }

    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
            
            TextField("Search lists...", text: $searchText)
                .textFieldStyle(.plain)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding(12)
        .background(Color(.tertiarySystemGroupedBackground))
        .cornerRadius(12)
    }
    
    private var packingListsGrid: some View {
        LazyVStack(spacing: 8) {
            ForEach(filteredLists) { list in
                PackingListCard(list: list, showUserPill: showUserPill)
            }
        }
        .padding(.horizontal)
    }

    
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "suitcase")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("No Lists Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            if !searchText.isEmpty || selectedUser != nil || selectedListType != nil {
                Text("Try adjusting your filters")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    withAnimation {
                        searchText = ""
                        selectedUser = nil
                        selectedListType = nil
                    }
                } label: {
                    Text("Clear All Filters")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            } else {
                Text("Create your first packing list to get started")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Button {
                    showingAddSheet.toggle()
                } label: {
                    Text("Create Packing List")
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
            }
        }
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
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

struct PackingListCard: View {
    let list: PackingList
    let showUserPill: Bool
    
    var body: some View {
        NavigationLink(destination: PackingListDetailView(packingList: list)) {
            HStack(spacing: 12) {
                // Left side: Name and user pill
                HStack(spacing: 8) {
                    Text(list.name)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .lineLimit(1)
                    
                    if let user = list.user, showUserPill {
                        user.pillFirstInitialIcon
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

