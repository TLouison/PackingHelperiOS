//
//  PackingListSelectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/28/24.
//

import SwiftUI
import SwiftData

struct PackingListSelectionView: View {
    @Binding var packingLists: [PackingList]
    
    @State private var searchText = ""
    
    @State private var isShowingDefaultPackingListAddSheet: Bool = false
    
    @Query(
        filter: #Predicate<PackingList>{ $0.template == true },
        sort: \.created, order: .reverse,
        animation: .snappy
    ) private var defaultPackingListOptions: [PackingList]
    
    var searchResults: [PackingList] {
        if searchText.isEmpty {
            return defaultPackingListOptions
        } else {
            return defaultPackingListOptions.filter { $0.name == (searchText) }
        }
    }
    
    func addToSelected(_ list: PackingList) {
        packingLists.append(list)
    }
    
    func removeFromSelected(_ list: PackingList) {
        let index = packingLists.firstIndex(of: list)
        if let index {
            packingLists.remove(at: index)
        }
    }
    
    var body: some View {
        VStack {
            PackingListPillView(packingLists: packingLists)
            
            if defaultPackingListOptions.isEmpty {
                ContentUnavailableView {
                    Label("No Default Packing Lists", systemImage: "suitcase.rolling.fill")
                } description: {
                    Text("You haven't created any default packing lists! Visit the home screen to create a new list.")
                }
            } else {
                List {
                    ForEach(searchResults, id: \.id) { packingList in
                        HStack {
                            Text(packingList.name)
                            Spacer()
                            
                            if packingLists.contains(packingList) {
                                Button {
                                    withAnimation {
                                        removeFromSelected(packingList)
                                    }
                                } label: {
                                    Label("Remove \(packingList.name) from packing lists", systemImage: "minus.circle.fill")
                                        .labelStyle(.iconOnly)
                                        .foregroundStyle(.red)
                                }
                            } else {
                                Button {
                                    withAnimation {
                                        addToSelected(packingList)
                                    }
                                } label: {
                                    Label("Add \(packingList.name) to packing lists", systemImage: "plus.circle.fill")
                                        .labelStyle(.iconOnly)
                                }
                            }
                        }
                    }
                    .listRowBackground(Color(.secondarySystemBackground))
                }
                .navigationTitle("Default Packing Lists")
                .scrollContentBackground(.hidden)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search For Packing Lists")
    }
}
