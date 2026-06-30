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
    @Environment(\.modelContext) private var modelContext

    let trip: Trip
    var listType: ListType? = nil
    var isDayOf: Bool? = nil

    @State private var selectedUser: User?
    @State private var selectedLists: [PackingList] = []
    @State private var featureFlags = FeatureFlags.shared
    @State private var searchText = ""
    @State private var selectedListType: ListType?
    @State private var showingFilters = false
    @State private var showingOtherLists = false

    @Query(
        filter: #Predicate<PackingList> { $0.template == true },
        sort: [SortDescriptor(\.name)],
        animation: .snappy
    )
    private var defaultPackingLists: [PackingList]

    private var canSave: Bool { !selectedLists.isEmpty }

    private var filteredLists: [PackingList] {
        defaultPackingLists.filter { list in
            !trip.alreadyUsedTemplates.contains(list) &&
            (selectedUser == nil || list.user == selectedUser) &&
            (listType != nil ? list.type == listType : selectedListType == nil || list.type == selectedListType) &&
            (searchText.isEmpty || list.name.localizedCaseInsensitiveContains(searchText))
        }
    }

    private var primaryLists: [PackingList] {
        guard let isDayOf else { return filteredLists }
        return filteredLists.filter { $0.isDayOf == isDayOf }
    }

    private var secondaryLists: [PackingList] {
        guard let isDayOf else { return [] }
        return filteredLists.filter { $0.isDayOf != isDayOf }
    }

    private var templateSectionTitle: String {
        guard let isDayOf else { return "Templates" }
        if isDayOf { return "Day-Of Templates" }
        switch listType {
        case .task: return "Task Templates"
        default: return "Packing Templates"
        }
    }

    private var hasActiveFilters: Bool {
        (listType == nil && selectedListType != nil) || !searchText.isEmpty
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if showingFilters {
                    PackingListFilterSection(
                        searchText: $searchText,
                        selectedListType: $selectedListType,
                        selectedUser: .constant(selectedUser),
                        users: [],
                        showUserFilter: false,
                        showTypeFilter: listType == nil,
                        hasActiveFilters: hasActiveFilters,
                        onClearFilters: clearFilters
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                }

                List {
                    if featureFlags.showingMultiplePackers {
                        Section {
                            UserSelectionRow(selectedUser: $selectedUser)
                                .onChange(of: selectedUser) {
                                    selectedLists.removeAll()
                                }
                        } header: {
                            Text("Select Packer")
                        } footer: {
                            Text(selectedUser == nil ?
                                 "Lists will be applied to the packer who created it" :
                                 "Lists will be applied to \(selectedUser?.name ?? "")")
                        }
                    }

                    Section {
                        if filteredLists.isEmpty {
                            Text(hasActiveFilters ?
                                 "No templates match your filters" :
                                 "No templates available to select")
                                .foregroundStyle(.secondary)
                                .font(.subheadline)
                        } else {
                            ForEach(isDayOf != nil ? primaryLists : filteredLists) { list in
                                templateRow(list)
                            }
                        }
                    } header: {
                        HStack {
                            Text(templateSectionTitle)
                            if !selectedLists.isEmpty {
                                Spacer()
                                Button("Clear All") {
                                    withAnimation { selectedLists.removeAll() }
                                }
                                .foregroundStyle(.red)
                                .font(.footnote)
                                .fontWeight(.regular)
                                .textCase(nil)
                            }
                        }
                    }

                    if !secondaryLists.isEmpty {
                        Section {
                            DisclosureGroup(isExpanded: $showingOtherLists) {
                                ForEach(secondaryLists) { list in
                                    templateRow(list)
                                }
                            } label: {
                                Text("Other Templates")
                            }
                        }
                    }

                    if !trip.alreadyUsedTemplates.isEmpty {
                        Section {
                            AppliedListsView(lists: trip.alreadyUsedTemplates)
                        } header: {
                            Text("Already Applied")
                        } footer: {
                            Text("These templates have already been applied and cannot be selected again")
                        }
                    }
                }
            }
            .navigationTitle("Apply Templates")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel) {
                        dismiss()
                    }
                }

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

    @ViewBuilder
    private func templateRow(_ list: PackingList) -> some View {
        Button(action: { toggleSelection(for: list) }) {
            HStack(spacing: 12) {
                HStack(spacing: 8) {
                    Text(list.name)
                        .font(.body)
                        .fontWeight(.medium)
                        .lineLimit(1)
                        .foregroundStyle(.primary)

                    if selectedLists.contains(list) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.blue)
                    }
                }

                Spacer()

                HStack(spacing: 4) {
                    Text("\(list.totalItems)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    list.iconImage
                        .foregroundStyle(Color.accentColor)
                        .font(.subheadline)
                }
            }
        }
        .buttonStyle(.plain)
    }

    private func save() {
        trip.applyDefaultLists(to: selectedUser, lists: selectedLists, in: modelContext)
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
