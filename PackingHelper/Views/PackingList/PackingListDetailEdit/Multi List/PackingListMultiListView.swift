//
//  PackingListMultiListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import SwiftData

// TODO: Figure out how to get this to work
//enum MultiPackCurrentView {
//    case base
//    case addItem(PackingList)
//    case editList(PackingList)
//}

struct PackingListMultiListView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var listType: ListType
    var trip: Trip
    let user: User?

    @State private var currentView: PackingListDetailViewCurrentSelection = .unpacked
    @State private var isShowingListSettings: Bool = false
    @State private var isShowingSaveSuccessful: Bool = false
    @State private var isDeleted: Bool = false
    
    @State private var selectedList: PackingList?
    @State private var isShowingAddItem: Bool = false
    @State private var isShowingEditList: Bool = false

    var shouldShowAddItemSheet: Bool {
        return currentView == .unpacked && isShowingAddItem && selectedList != nil
    }
    
    var shouldShowEditListSheet: Bool {
        return isShowingEditList && selectedList != nil
    }
    
    func shouldShowSection(list: PackingList) -> Bool {
        if currentView == .packed && !list.completeItems.isEmpty {
            return true
        } else if currentView == .unpacked && !list.incompleteItems.isEmpty {
            return true
        }
        return false
    }
    
    var listsForUser: [PackingList] {
        let lists = trip.getLists(for: listType)
        if let user {
            return lists.filter{ $0.user == user }
        } else {
            return lists
        }
    }
    
    @ViewBuilder func listView(currentView: PackingListDetailViewCurrentSelection) -> some View {
        List {
            ForEach(listsForUser, id: \.id) { packingList in
                PackingListMultiListEditView(packingList: packingList, user: user, currentView: .constant(currentView), selectedList: $selectedList, isAddingNewItem: $isShowingAddItem, isShowingEditList: $isShowingEditList)
            }
        }
        .listStyle(.inset)
        .listRowSeparator(.hidden)
        .listSectionSeparator(.hidden)
    }
    
    var body: some View {
        VStack {
            PackingListDetailEditTabBarView(listType: listType, currentView: $currentView)
                .padding(.top)
            
            // Having two instances of the same view so that we can nicely transition
            // between states.
            if currentView == .unpacked {
                listView(currentView: .unpacked)
                    .transition(.pushAndPull(.leading))
                    .listRowSeparator(.hidden)
            } else {
                listView(currentView: .packed)
                    .transition(.pushAndPull(.trailing))
            }
            
            if (trip.getTotalItems(for: listType) == 0) {
                ContentUnavailableView {
                    Label("No Items On List", systemImage: "bag")
                } description: {
                    Text("You haven't added any items to your list. Add one now to start your packing!")
                }
            }
        }
        .navigationTitle(listType.rawValue)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                TripDetailPackingProgressView(
                    val: Double(trip.getCompleteItems(for: listType)),
                    total: Double(trip.getTotalItems(for: listType)),
                    image: PackingList.icon(listType: listType)
                )
                .scaleEffect(x: 0.5, y: 0.5)
            }
        }
        .sheet(isPresented: $isShowingAddItem) {
            PackingAddItemForGroupView(selectedPackingList: $selectedList, availableLists: listsForUser)
                .presentationDetents([.height(200)])
        }
        .sheet(isPresented: $isShowingEditList) {
            PackingListEditView(packingList: selectedList, isTemplate: false, isDeleted: $isDeleted)
        }
        .onChange(of: shouldShowAddItemSheet) {
            // If the value of shouldShowAddItemSheet changed, one of the conditions
            // updated so we should change the binding too
            isShowingAddItem = shouldShowAddItemSheet
        }
        .onChange(of: shouldShowEditListSheet) {
            isShowingEditList = shouldShowEditListSheet
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    PackingListMultiListView(listType: .packing, trip: trips.first!, user: nil)
}
