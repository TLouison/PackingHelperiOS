//
//  TripPackingSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import Combine
import SwiftUI
import SwiftData

struct TripPackingBoxView: View {
    var trip: Trip
    
    @Binding var isAddingNewPackingList: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    
    @Query(animation: .bouncy) private var lists: [PackingList]
    @Query private var users: [User]
    @State private var selectedUser: User?

    // Get the packing lists for the provided user
    var packingLists: [PackingList] {
        if let selectedUser {
            return trip.lists?.filter( { $0.user == selectedUser } ) ?? []
        } else {
            return trip.lists ?? []
        }
    }
    
    var visibleListTypes: [ListType] {
        let listTypes = Set(packingLists.map{ $0.type })
        return listTypes.sorted()
    }
    
    var defaultListsExist: Bool {
        return !lists.filter{ $0.template == true }.isEmpty
    }
    
    var body: some View {
            TripDetailCustomSectionView {
                HStack {
                    Text("Packing Lists")
                        .font(.title)
                    Spacer()
                    
                    createListMenu()
                }
            } content: {
                if !(trip.lists?.isEmpty ?? true) {
                    VStack(alignment: .center) {
                        if trip.hasMultiplePackers {
                            UserPickerView(selectedUser: $selectedUser)
                                .transition(.scale)
                        }
                        
                        ForEach(visibleListTypes, id: \.rawValue) { listType in
                            NavigationLink {
                                PackingListMultiListView(listType: listType, trip: trip, user: $selectedUser)
                            } label: {
                                HStack {
                                    Text(listType.rawValue).font(.headline)
                                    Spacer()
                                    TripDetailPackingProgressView(
                                        val: Double(trip.getCompleteItems(for: listType)),
                                        total: Double(trip.getTotalItems(for: listType)),
                                        image: PackingList.icon(listType: listType)
                                    )
                                    .scaleEffect(x: 0.75, y: 0.75)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: 30)
                            .roundedBox(background: .ultraThick)
                            .shaded()
                        }
                    }
                }
        }
    }
    
    @ViewBuilder func createListMenu() -> some View {
        if defaultListsExist {
            Menu {
                Button("Create List") {
                    withAnimation {
                        isAddingNewPackingList.toggle()
                    }
                }
                Button("Apply Default List") {
                    withAnimation {
                        isApplyingDefaultPackingList.toggle()
                    }
                }
            } label: {
                Label("Create List", systemImage: "plus.circle")
            }
        } else {
            Button {
                withAnimation {
                    isAddingNewPackingList.toggle()
                }
            } label: {
                Label("Create List", systemImage: "plus.circle")
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    @Previewable @State var addingList = false
    @Previewable @State var applyingDefault = false
    TripPackingBoxView(trip: trips.first!, isAddingNewPackingList: $addingList, isApplyingDefaultPackingList: $applyingDefault)
}
