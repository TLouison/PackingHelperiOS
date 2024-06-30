//
//  MultipackView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/30/24.
//

import SwiftUI
import SwiftData

struct MultipackView: View {
    var trip: Trip
    var listType: ListType
    
    @Binding var selectedUser: User?
    
    @State private var selectedList: PackingList?
    @State private var sortOrder: PackingListSortOrder = .byDate
    @State private var currentView: PackingListDetailViewCurrentSelection = .unpacked
    
    @State private var isCreatingNewList: Bool = false
    @State private var isApplyingDefaultList: Bool = false
    
    @Query private var packingLists: [PackingList]
    
    init(trip: Trip, listType: ListType, user: Binding<User?>) {
        self._selectedUser = user
        
        self.trip = trip
        self.listType = listType
        
        let tripID = self.trip.uuid
        let predicate = #Predicate<PackingList>{ list in
            list.trip?.uuid == tripID && list.template == false
        }
        self._packingLists = Query(filter: predicate)
    }
    
    var visibleLists: [PackingList] {
        var lists = packingLists.filter { $0.type == listType }
        if let selectedUser {
            lists = lists.filter { $0.user == selectedUser }
        }
        return lists
    }
    
    var sortedLists: [PackingList] {
        return PackingList.sorted(visibleLists, sortOrder: sortOrder)
    }
    
    var body: some View {
        VStack {
            PackingListDetailEditTabBarView(listType: listType, currentView: $currentView)
            
            // By using a conditional we can transition between the two views
            // as if they were different pages, instead of just removing and
            // adding items to them
            switch currentView {
            case .unpacked:
                MultipackListView(
                    trip: trip,
                    packingLists: sortedLists,
                    selectedUser: $selectedUser,
                    currentView: .unpacked,
                    listType: listType
                )
                .transition(.pushAndPull(.leading))
            case .packed:
                MultipackListView(
                    trip: trip,
                    packingLists: sortedLists,
                    selectedUser: $selectedUser,
                    currentView: .packed,
                    listType: listType
                )
                .transition(.pushAndPull(.trailing))
            }
        }
        .navigationTitle(listType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                MultipackFilterAndSortMenu(
                    user: $selectedUser,
                    selectedList: $selectedList,
                    sortOrder: $sortOrder,
                    isShowingEditList: $isCreatingNewList,
                    isApplyingDefaultPackingList: $isApplyingDefaultList
                )
                
                TripDetailPackingProgressView(
                    val: Double(trip.getCompleteItems(for: listType)),
                    total: Double(trip.getTotalItems(for: listType)),
                    image: PackingList.icon(listType: listType)
                )
                .scaleEffect(x: 0.5, y: 0.5)
            }
        }
        .sheet(isPresented: $isApplyingDefaultList) {
            PackingListApplyDefaultView(trip: trip)
        }
        .sheet(isPresented: $isCreatingNewList) {
            PackingListEditView(
                packingList: nil,
                isTemplate: false,
                trip: trip,
                forceListType: listType,
                isDeleted: .constant(false)
            )
        }
        .onChange(of: selectedUser) { before, after in
            if before == nil && after != nil {
                sortOrder = .byDate
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    MultipackView(trip: trips.first!, listType: .packing, user: .constant(nil))
}
