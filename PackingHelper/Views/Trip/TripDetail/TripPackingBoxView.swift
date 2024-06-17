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
    
    @Query private var users: [User]
    @State private var selectedUser: User?

    // Get the packing lists for the provided user
    var packingLists: [PackingList] {
        if let selectedUser {
            return trip.lists.filter( { $0.user == selectedUser } )
        } else {
            return trip.lists
        }
    }
    
    var visibleLists: [PackingList] {
        return packingLists.filter{ $0.trip == trip }.sorted(by: {$0.type < $1.type})
    }
    
    var defaultListsExist: Bool {
        return !packingLists.filter{ $0.template == true }.isEmpty
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
                if !trip.lists.isEmpty {
                    if trip.totalListEntries > 0 {
                        HStack {
                            ForEach(ListType.allCases, id: \.rawValue) { listType in
                                if trip.getTotalItems(for: listType) > 0 {
                                    packingProgressView(
                                        val: Double(trip.getCompleteItems(for: listType)),
                                        total: Double(trip.getTotalItems(for: listType)),
                                        image: PackingList.icon(listType: listType)
                                    )
                                    .onChange(of: trip.getTotalItems(for: listType)) {
                                        print(trip.getCompleteItems(for: listType), trip.getTotalItems(for: listType))
                                    }
                                    .padding(.horizontal)
                                }
                            }
                        }
                    }
                    
                    VStack(alignment: .center) {
                        UserPickerView(selectedUser: $selectedUser)
                        
                        ForEach(visibleLists) { list in
                            NavigationLink {
                                PackingListDetailView(packingList: list)
                            } label: {
                                Label(list.name, systemImage: list.icon)
                            }
                            .frame(maxWidth: .infinity)
                            .roundedBox(background: .ultraThick)
                        }
                    }
                }
        }
    }
    
    @ViewBuilder func packingProgressView(val: Double, total: Double, image: String) -> some View {
        HStack {
            Gauge(value: val, in: 0...total) {
                Image(systemName: image)
                    .imageScale(.small)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(val == total ? .green : .accent)
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
