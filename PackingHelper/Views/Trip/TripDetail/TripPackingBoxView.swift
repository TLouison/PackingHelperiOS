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
    
    var visibleLists: [PackingList] {
        return packingLists.filter{ $0.trip == trip }.sorted(by: {$0.type < $1.type})
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
                        if trip.totalListEntries > 0 {
                            TripDetailPackingGaugeRowView(trip: trip)
                        }
                        
                        if trip.hasMultiplePackers {
                            UserPickerView(selectedUser: $selectedUser)
                                .transition(.scale)
                        }
                        
                        ForEach(visibleListTypes, id: \.rawValue) { listType in
                            NavigationLink {
                                PackingListMultiListView(listType: listType, trip: trip, user: selectedUser)
                            } label: {
                                Label(listType.rawValue, systemImage: listType.icon)
                            }
                            .frame(maxWidth: .infinity)
                            .roundedBox(background: .ultraThick)
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
