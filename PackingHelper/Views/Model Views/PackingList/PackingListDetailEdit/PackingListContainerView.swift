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
    @State var lists: [PackingList]
    let users: [User]?
    let listType: ListType
    let isDayOf: Bool
    let title: String?
    let trip: Trip
    
    @State private var editingList: PackingList? = nil
    @State private var showingAddListSheet: Bool = false
    @State private var isApplyingDefaultPackingList: Bool = false
    @State private var isAddingNewItem: Bool = false

    @AppStorage("packingListViewMode") private var viewMode: PackingListViewMode = .unified

    var body: some View {
        Group {
            switch viewMode {
            case .unified:
                UnifiedPackingListView(
                    lists: lists,
                    users: users,
                    listType: listType,
                    isDayOf: isDayOf,
                    title: title,
                    mode: .unified,
                    isAddingNewItem: $isAddingNewItem,
                    editingList: $editingList,
                    showingAddListSheet: $showingAddListSheet,
                    isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                )
            case .sectioned:
                SectionedPackingListView(
                    lists: lists,
                    users: users,
                    listType: listType,
                    isDayOf: isDayOf,
                    title: title,
                    trip: trip,
                    isAddingNewItem: $isAddingNewItem,
                    editingList: $editingList,
                    showingAddListSheet: $showingAddListSheet,
                    isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                )
            }
        }
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
                .padding(.bottom, 20)
            }
        }
        .sheet(item: $editingList) { list in
            PackingListEditView(packingList: list, trip: trip, isDeleted: .constant(false))
        }
        .sheet(isPresented: $showingAddListSheet) {
            AddPackingListSheet(listType: listType, isDayOf: isDayOf, users: users, onAdd: { _ in })
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
