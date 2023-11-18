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

    @Query(animation: .snappy) private var packingLists: [PackingList]
    
    var visibleLists: [PackingList] {
        return packingLists.filter{ $0.trip == trip }.sorted(by: {$0.type < $1.type})
    }
    
    var defaultListsExist: Bool {
        return !packingLists.filter{ $0.template == true }.isEmpty
    }
    
    var body: some View {
        VStack {
            HStack {
                Text("Packing Lists")
                    .font(.title)
                Spacer()
                
                createListMenu()
                    .roundedBox(background: .ultraThickMaterial)
                    .shaded()
            }
            
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
                } else {
                    Divider()
                }
                
                VStack {
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
                .padding(.vertical)
            }
            
        }
        .roundedBox()
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
