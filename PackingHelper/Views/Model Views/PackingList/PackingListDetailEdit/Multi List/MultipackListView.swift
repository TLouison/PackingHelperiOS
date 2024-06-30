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
    @State var selectedListToEdit: PackingList?
    @State var selectedListToAdd: PackingList?
    
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
                    selectedListToAdd: $selectedListToAdd,
                    selectedListToEdit: $selectedListToEdit,
                    isDeleted: $isDeleted
                )
            }
        }
        .listStyle(.inset)
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
        .sheet(item: $selectedListToEdit) { list in
            PackingListEditView(
                packingList: list,
                isTemplate: false,
                trip: trip,
                forceListType: listType,
                isDeleted: $isDeleted
            )
        }
        .sheet(item: $selectedListToAdd) { _ in
            PackingAddItemForGroupView(
                selectedPackingList: $selectedListToAdd,
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
