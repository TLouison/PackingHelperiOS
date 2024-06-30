//
//  MultipackListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/30/24.
//

import SwiftUI

struct MultipackListView: View {
    @Bindable var trip: Trip
    var packingLists: [PackingList]
    
    @Binding var selectedUser: User?
    @Binding var selectedList: PackingList?
    @Binding var isShowingEditList: Bool
    
    @State private var isShowingAddItem: Bool = false
    @State private var isDeleted: Bool = false
    
    let currentView: PackingListDetailViewCurrentSelection
    let listType: ListType
    
    var body: some View {
        List {
            ForEach(packingLists, id: \.id) { packingList in
                MultipackListRowView(
                    packingList: packingList, 
                    trip: trip,
                    user: selectedUser,
                    listType: listType,
                    currentView: currentView,
                    selectedList: $selectedList,
                    isAddingNewItem: $isShowingAddItem,
                    isShowingEditList: $isShowingEditList,
                    isDeleted: $isDeleted
                )
            }
        }
        .listStyle(.inset)
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .sheet(isPresented: $isShowingEditList) {
            PackingListEditView(
                packingList: selectedList,
                isTemplate: false,
                trip: trip,
                forceListType: listType,
                isDeleted: $isDeleted
            )
        }
        .sheet(isPresented: $isShowingAddItem) {
            PackingAddItemForGroupView(
                selectedPackingList: $selectedList,
                availableLists: trip.getLists(for: selectedUser, ofType: listType).sorted {
                    $0.name < $1.name
                },
                currentView: currentView)
                .presentationDetents([.height(200)])
        }
    }
}

//#Preview {
//    MultipackListView()
//}
