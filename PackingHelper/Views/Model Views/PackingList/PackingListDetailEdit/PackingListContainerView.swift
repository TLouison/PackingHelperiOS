//
//  PackingListContainerView.swift
//  PackingHelper
//
//  A container view that manages switching between UnifiedPackingListView
//  and SectionedPackingListView, and provides shared toolbar functionality.
//
//  Created by Claude on 1/11/26.
//

import SwiftUI
import SwiftData

struct PackingListContainerView: View {
    let users: [User]?
    let listType: ListType
    let isDayOf: Bool
    let title: String?
    let trip: Trip

    @State private var editingList: PackingList? = nil
    @State private var showingAddListSheet: Bool = false
    @State private var isApplyingDefaultPackingList: Bool = false
    @State private var isAddingNewItem: Bool = false
    @State private var selectedUser: User?

    @AppStorage("packingListViewMode") private var viewMode: PackingListViewMode = .unified

    private var lists: [PackingList] {
        trip.lists ?? []
    }

    private var hasMultiplePackers: Bool {
        guard let users = users else { return false }
        return users.count > 1
    }

    private var filteredLists: [PackingList] {
        let filtered = lists.filter { list in
            let typeMatch = list.type == listType && list.isDayOf == isDayOf
            if let selectedUser = selectedUser {
                return list.user == selectedUser && typeMatch
            } else {
                return typeMatch
            }
        }
        return PackingList.sorted(filtered, sortOrder: .byDate)
    }

    var body: some View {
        ZStack {
            Color(UIColor.systemGroupedBackground)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // User selector if multiple packers
                if hasMultiplePackers {
                    UserSelector(
                        users: users ?? [],
                        selectedUser: $selectedUser
                    )
                }

                Group {
                    switch viewMode {
                    case .unified:
                        UnifiedPackingListView(
                            trip: trip,
                            users: users,
                            listType: listType,
                            isDayOf: isDayOf,
                            title: title,
                            mode: .unified,
                            isAddingNewItem: $isAddingNewItem,
                            editingList: $editingList,
                            showingAddListSheet: $showingAddListSheet,
                            isApplyingDefaultPackingList: $isApplyingDefaultPackingList,
                            selectedUser: $selectedUser
                        )
                    case .sectioned:
                        SectionedPackingListView(
                            users: users,
                            listType: listType,
                            isDayOf: isDayOf,
                            title: title,
                            trip: trip,
                            isAddingNewItem: $isAddingNewItem,
                            editingList: $editingList,
                            showingAddListSheet: $showingAddListSheet,
                            isApplyingDefaultPackingList: $isApplyingDefaultPackingList,
                            selectedUser: $selectedUser
                        )
                    }
                }

                PackingSummaryBar(packingLists: filteredLists)
            }
        }
        .navigationTitle(title ?? "Packing")
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            VStack {
                Spacer()
                
                HStack {
                    Spacer()

                    Group {
                        if isAddingNewItem {
                            Button(action: cancelAddingNewItem) {
                                Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 60, height: 60)
                            .glassEffectIfAvailable()
                        } else {
                            Button(action: startAddingNewItem) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 60, height: 60)
                            .glassEffectIfAvailable()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 75)
            }
        }
        .sheet(item: $editingList) { list in
            PackingListEditView(packingList: list, trip: trip, isDeleted: .constant(false))
        }
        .sheet(isPresented: $showingAddListSheet) {
            AddPackingListSheet(trip: trip, listType: listType, isDayOf: isDayOf, users: users, onAdd: { _ in })
                .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $isApplyingDefaultPackingList) {
            PackingListApplyDefaultView(trip: trip)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                // Menu with view toggle + add list
                Menu {
                    Button {
                        viewMode = viewMode == .unified ? .sectioned : .unified
                    } label: {
                        Label(
                            viewMode == .unified ? "View by List" : "View Unified",
                            systemImage: viewMode == .unified ? "list.bullet.indent" : "list.bullet"
                        )
                    }

                    Divider()

                    Button {
                        showingAddListSheet.toggle()
                    } label: {
                        Label("Create List", systemImage: "plus")
                    }

                    Button {
                        isApplyingDefaultPackingList.toggle()
                    } label: {
                        Label("Apply Template List", systemImage: "doc.on.doc")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
    }

    private func startAddingNewItem() {
        withAnimation {
            isAddingNewItem = true
        }
    }

    private func cancelAddingNewItem() {
        withAnimation {
            isAddingNewItem = false
        }
    }
}
