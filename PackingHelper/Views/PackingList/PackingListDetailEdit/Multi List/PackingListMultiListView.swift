//
//  PackingListMultiListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI
import SwiftData

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
    
    @State private var isShowingAddItem: Bool = false
    @State private var listToAddItemTo: PackingList?
    
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
                CollapsibleSection {
                    HStack {
                        Text(packingList.name)
                        
                        if user == nil {
                            if let pUser = packingList.user {
                                pUser.pillIcon
                            }
                        }
                    }
                } content: {
                    PackingListMultiListEditView(packingList: packingList, currentView: .constant(currentView), isAddingNewItem: $isShowingAddItem, listToAddTo: $listToAddItemTo)
                }
            }
        }
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
            } else {
                listView(currentView: .packed)
                    .transition(.pushAndPull(.trailing))
            }
//                ForEach(PackingListDetailViewCurrentSelection.allCases, id: \.hashValue) { currentView in
//                    listView(currentView: currentView)
//                }
            
            if (trip.getTotalItems(for: listType) == 0) {
                ContentUnavailableView {
                    Label("No Items On List", systemImage: "bag")
                } description: {
                    Text("You haven't added any items to your list. Add one now to start your packing!")
                }
            }
            
            if currentView == .unpacked && isShowingAddItem {
                if let listToAddItemTo {
                    Spacer()
                    
                    PackingAddItemView(packingList: listToAddItemTo)
                        .padding(.bottom)
                        .transition(.pushAndPull(.bottom))
//                        .onChange(of: listToAddItemTo.items) {
//                            withAnimation {
//                                isShowingAddItem = false
//                            }
//                        }
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
        .alert("List saved as default", isPresented: $isShowingSaveSuccessful) {
            Button("OK", role: .cancel) {}
        }
//        .sheet(isPresented: $isShowingListSettings) {
//            PackingListEditView(packingList: packingList, isTemplate: packingList.template, isDeleted: $isDeleted)
//                .presentationDetents([.height(250)])
//        }
        .onChange(of: isDeleted) {
            dismiss()
        }
    }
    
//    func saveListAsDefault() {
//        let newDefaultList = PackingList.copyAsTemplate(self.packingList)
//        modelContext.insert(newDefaultList)
//        
//        isShowingSaveSuccessful = true
//    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    PackingListMultiListView(listType: .packing, trip: trips.first!, user: nil)
}
