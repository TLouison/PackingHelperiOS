//
//  TripPackingSheet.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/11/23.
//

import SwiftUI
import SwiftData

struct TripDetailPackingView: View {
    let trip: Trip
    
    @Query var lists: [PackingList]
    
    @Binding var isAddingNewPackingList: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    
    @State private var selectedUser: User?
    
    var filteredLists: [PackingList] {
        lists.filter { $0.tripID == trip.id }
    }
    
    var body: some View {
        TripDetailCustomSectionView {
            HStack {
                Text("Packing Lists")
                    .font(.title)
                Spacer()
                
                CreateListMenu(
                    isAddingNewPackingList: $isAddingNewPackingList,
                    isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                )
            }
        } content: {
            if filteredLists.isEmpty {
                ContentUnavailableView{
                    Label("No Packing Lists", systemImage: suitcaseIcon)
                } description: {
                    Text("You haven't added any packing lists to this trip!")
                } actions: {
                    CreateListMenu(
                        isAddingNewPackingList: $isAddingNewPackingList,
                        isApplyingDefaultPackingList: $isApplyingDefaultPackingList
                    )
                }
            }
            if !filteredLists.isEmpty {
                VStack(alignment: .center) {
                    if trip.hasMultiplePackers {
                        UserPickerView(selectedUser: $selectedUser)
                            .transition(.scale)
                    }
                    
                    
                    ForEach(trip.containsListTypes, id: \.rawValue) { listType in
                        NavigationLink {
                            UnifiedPackingListView(
                                lists: filteredLists.filter { $0.type == listType },
                                users: trip.packers,
                                listType: listType,
                                title: trip.name,
                                mode: .unified,
                            )
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
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var trips: [Trip]
    @Previewable @State var addingList = false
    @Previewable @State var applyingDefault = false
    TripDetailPackingView(trip: trips.first!, isAddingNewPackingList: $addingList, isApplyingDefaultPackingList: $applyingDefault)
}
