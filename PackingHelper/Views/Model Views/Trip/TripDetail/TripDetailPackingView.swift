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
        lists.filter { $0.trip?.id == trip.id }
    }
    
    var body: some View {
        TripDetailCustomSectionView {
            HStack {
                Text("Packing Lists")
                    .font(.title)
                Spacer()
                
                CreateListMenu(
                    isAddingNewPackingList: $isAddingNewPackingList,
                    isApplyingDefaultPackingList: $isApplyingDefaultPackingList,
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
                        isApplyingDefaultPackingList: $isApplyingDefaultPackingList,
                    )
                }
            }
            if !filteredLists.isEmpty {
                VStack(alignment: .center) {
                    if trip.hasMultiplePackers {
                        UserPickerView(selectedUser: $selectedUser)
                            .transition(.scale)
                    }

                    // Regular list sections (non-Day-of)
                    ForEach(ListType.allCases, id: \.rawValue) { listType in
                        let regularLists = filteredLists.filter { $0.type == listType && !$0.isDayOf }
                        if !regularLists.isEmpty {
                            NavigationLink {
                                PackingListContainerView(
                                    users: trip.packers,
                                    listType: listType,
                                    isDayOf: false,
                                    title: trip.name,
                                    trip: trip
                                )
                            } label: {
                                HStack {
                                    Text(listType.rawValue).font(.headline)
                                    Spacer()
                                    TripDetailPackingProgressView(
                                        val: Double(trip.getCompleteItems(for: listType, isDayOf: false)),
                                        total: Double(trip.getTotalItems(for: listType, isDayOf: false)),
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

                    // Day-of section divider (only if Day-of lists exist)
                    if trip.containsDayOfPacking || trip.containsDayOfTask {
                        Divider()
                            .padding(.vertical, 8)

                        Text("Day-of")
                            .font(.headline)
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }

                    // Day-of Packing section
                    let dayOfPackingLists = filteredLists.filter { $0.type == .packing && $0.isDayOf }
                    if !dayOfPackingLists.isEmpty {
                        NavigationLink {
                            UnifiedPackingListView(
                                trip: trip,
                                users: trip.packers,
                                listType: .packing,
                                isDayOf: true,
                                title: "\(trip.name) - Day-of",
                                mode: .unified
                            )
                        } label: {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "sun.horizon")
                                        .foregroundStyle(.orange)
                                    Text("Day-of Packing").font(.headline)
                                }
                                Spacer()
                                TripDetailPackingProgressView(
                                    val: Double(trip.getCompleteItems(for: .packing, isDayOf: true)),
                                    total: Double(trip.getTotalItems(for: .packing, isDayOf: true)),
                                    image: "sun.horizon"
                                )
                                .scaleEffect(x: 0.75, y: 0.75)
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        .roundedBox(background: .ultraThick)
                        .shaded()
                    }

                    // Day-of Task section
                    let dayOfTaskLists = filteredLists.filter { $0.type == .task && $0.isDayOf }
                    if !dayOfTaskLists.isEmpty {
                        NavigationLink {
                            UnifiedPackingListView(
                                trip: trip,
                                users: trip.packers,
                                listType: .task,
                                isDayOf: true,
                                title: "\(trip.name) - Day-of",
                                mode: .unified
                            )
                        } label: {
                            HStack {
                                HStack(spacing: 4) {
                                    Image(systemName: "sun.horizon")
                                        .foregroundStyle(.orange)
                                    Text("Day-of Tasks").font(.headline)
                                }
                                Spacer()
                                TripDetailPackingProgressView(
                                    val: Double(trip.getCompleteItems(for: .task, isDayOf: true)),
                                    total: Double(trip.getTotalItems(for: .task, isDayOf: true)),
                                    image: "sun.horizon"
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
