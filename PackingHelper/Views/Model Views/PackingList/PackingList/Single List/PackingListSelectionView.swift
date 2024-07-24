//
//  PackingListSelectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/28/24.
//

import SwiftUI
import SwiftData

struct PackingListSelectionView: View {
    var trip: Trip?
    @Binding var selectedPackingLists: [PackingList]
    
    @Query(
        filter: #Predicate<PackingList> { $0.template == true },
        sort: \.name, order: .forward,
        animation: .snappy
    ) private var defaultPackingListOptions: [PackingList]
    
    @State private var searchText = ""
    @State private var isShowingDefaultPackingListAddSheet: Bool = false
    
    var user: User? = nil
    var lockToProvidedUser: Bool = false
    @State private var selectedUser: User? = nil
    
    var alreadyAppliedLists: [PackingList] {
        if let trip {
            return  trip.alreadyUsedTemplates
        } else {
            return []
        }
    }
    
    var availableLists: [PackingList] {
        print("\(alreadyAppliedLists.count) lists already applied to this trip for this user")
        let availableLists = defaultPackingListOptions.filter { !alreadyAppliedLists.contains($0) }
        return PackingList.filtered(user: selectedUser, availableLists)
    }
    
    var searchResults: [PackingList] {
        if searchText.isEmpty {
            return availableLists
        } else {
            return availableLists.filter { $0.name == (searchText) }
        }
    }
    
    var hasMultiplePackerOptions: Bool {
        return trip?.hasMultiplePackers ?? false || PackingList.containsMultiplePackers(defaultPackingListOptions)
    }
    
    func addToSelected(_ list: PackingList) {
        selectedPackingLists.append(list)
    }
    
    func removeFromSelected(_ list: PackingList) {
        let index = selectedPackingLists.firstIndex(of: list)
        if let index {
            selectedPackingLists.remove(at: index)
        }
    }
    
    var noListText: Text {
        if let user {
            if alreadyAppliedLists.isEmpty {
                return Text("\(user.name) has not created any default packing lists! Visit the Lists tab to create a new list.")
            } else {
                return Text("\(user.name) has already applied all their default packing lists! Visit the Lists tab to create a new list.")
            }
        } else {
            return Text("You haven't created any default packing lists! Visit the Lists tab to create a new list.")
        }
    }
    
    @ViewBuilder
    func addRemoveButton(_ packingList: PackingList) -> some View {
        switch selectedPackingLists.contains(packingList) {
        case true:
            Button {
                withAnimation {
                    removeFromSelected(packingList)
                }
            } label: {
                Label("Remove \(packingList.name) from packing lists", systemImage: "minus.circle.fill")
                    .labelStyle(.iconOnly)
                    .foregroundStyle(.red)
            }
        case false:
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
    
    var body: some View {
        VStack {
            PackingListPillView(packingLists: selectedPackingLists)
            
            if availableLists.isEmpty {
                ContentUnavailableView {
                    Label("No Default Packing Lists", systemImage: suitcaseIcon)
                } description: {
                    noListText
                }
            } else {
                List {
                    ForEach(searchResults, id: \.id) { packingList in
                        HStack {
                            PackingListRowView(packingList: packingList, showUserPill: hasMultiplePackerOptions)
                            
                            Spacer()
                            
                            addRemoveButton(packingList)
                        }
                    }
                    .listRowBackground(Color(.secondarySystemBackground))
                }
                .scrollContentBackground(.hidden)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search For Packing Lists")
        .navigationTitle("Default Packing Lists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                if !lockToProvidedUser {
                    Menu {
                        UserPickerBaseView(selectedUser: $selectedUser.animation())
                    } label: {
                        Image(systemName: "person.circle")
                    }
                }
            }
        }
        .onAppear {
            selectedUser = user
        }
    }
}
