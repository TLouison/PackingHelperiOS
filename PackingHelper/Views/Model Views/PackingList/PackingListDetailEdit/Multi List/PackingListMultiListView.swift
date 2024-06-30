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
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var listType: ListType
    @Bindable var trip: Trip
    @Binding var user: User?
    
    @State private var sortOrder: PackingListSortOrder = .byDate
    @State private var currentView: PackingListDetailViewCurrentSelection = .unpacked
    
    @State private var isShowingListSettings: Bool = false
    @State private var isShowingSaveSuccessful: Bool = false
    @State private var isDeleted: Bool = false
    
    @State private var selectedList: PackingList?
    @State private var isShowingAddItem: Bool = false
    @State private var isShowingEditList: Bool = false
    @State private var isApplyingDefaultPackingList: Bool = false
    
    func shouldShowSection(list: PackingList) -> Bool {
        if currentView == .packed && !list.completeItems.isEmpty {
            return true
        } else if currentView == .unpacked && !list.incompleteItems.isEmpty {
            return true
        }
        return false
    }

    var body: some View {
        VStack {
            PackingListDetailEditTabBarView(listType: listType, currentView: $currentView)
                .padding(.top)
            
            // Having two instances of the same view so that we can nicely transition
            // between states.
//            if currentView == .unpacked {
//                MultipackListView(
//                    trip: trip,
//                    user: $user,
//                    selectedList: $selectedList,
//                    sortOrder: $sortOrder,
//                    isShowingAddItem: $isShowingAddItem,
//                    isShowingEditList: $isShowingEditList,
//                    currentView: .unpacked,
//                    listType: listType
//                )
//                    .transition(.pushAndPull(.leading))
//                    .listRowSeparator(.hidden)
//            } else {
//                MultipackListView(
//                    trip: trip,
//                    user: $user,
//                    selectedList: $selectedList,
//                    sortOrder: $sortOrder,
//                    isShowingAddItem: $isShowingAddItem,
//                    isShowingEditList: $isShowingEditList,
//                    currentView: .packed,
//                    listType: listType
//                )
//                    .transition(.pushAndPull(.trailing))
//            }
//            
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
                MultipackFilterAndSortMenu(
                    user: $user,
                    selectedList: $selectedList,
                    sortOrder: $sortOrder,
                    isShowingEditList: $isShowingEditList,
                    isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                )
                
                TripDetailPackingProgressView(
                    val: Double(trip.getCompleteItems(for: listType)),
                    total: Double(trip.getTotalItems(for: listType)),
                    image: PackingList.icon(listType: listType)
                )
                .scaleEffect(x: 0.5, y: 0.5)
            }
        }
//        .sheet(isPresented: $isShowingAddItem) {
//            PackingAddItemForGroupView(
//                selectedPackingList: $selectedList,
//                availableLists: trip.getLists(for: user, ofType: listType).sorted {
//                    $0.name < $1.name
//                },
//                currentView: currentView)
//                .presentationDetents([.height(200)])
//        }
        .sheet(isPresented: $isShowingEditList) {
            PackingListEditView(packingList: selectedList, isTemplate: false, trip: trip, forceListType: listType, isDeleted: $isDeleted)
        }
        .sheet(isPresented: $isApplyingDefaultPackingList) {
            PackingListApplyDefaultView(trip: trip)
                .presentationDetents([.height(300)])
        }
        .onChange(of: user) {
            if user != nil {
                sortOrder = .byDate
            }
        }

    }
}

//@available(iOS 18, *)
//#Preview(traits: .sampleData) {
//    @Previewable @Query var trips: [Trip]
//    PackingListMultiListView(listType: .packing, trip: trips.first!, user: .constant(nil))
//}
