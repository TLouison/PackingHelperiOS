//
//  DefaultPackingListFilterView.swift
//  PackingHelper
//
//  Created by Todd Louison on 1/28/25.
//

import SwiftUI

// MARK: - Shared Components

struct PackingListFilterSection: View {
    @Binding var searchText: String
    @Binding var selectedListType: ListType?
    @Binding var selectedUser: User?
    let users: [User]
    let showUserFilter: Bool
    let hasActiveFilters: Bool
    
    var onClearFilters: () -> Void
    
    var body: some View {
        VStack(spacing: 12) {
            searchBar
            
            if showUserFilter {
                userFilterSection
            }
            
            listTypeFilterSection
            
            if hasActiveFilters {
                Button {
                    onClearFilters()
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
}

struct PackingListEmptyStateView: View {
    let hasFilters: Bool
    let message: String
    let actionButtonTitle: String
    let onAction: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Image(systemName: "suitcase")
                .font(.system(size: 48))
                .foregroundColor(.accentColor)
            
            Text("No Lists Found")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text(message)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button(action: onAction) {
                Text(actionButtonTitle)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 32)
        }
        .padding(32)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(16)
        .padding(.horizontal)
    }
}

