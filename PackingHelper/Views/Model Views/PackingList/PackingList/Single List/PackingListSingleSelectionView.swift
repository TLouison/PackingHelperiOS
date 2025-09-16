//
//  PackingListSelectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/28/24.
//

import SwiftUI
import SwiftData

struct PackingListSingleSelectionView: View {
    var trip: Trip?
    
    @Binding var selectedList: PackingList?
    var availableLists: [PackingList]
    
    @State private var searchText = ""
    @State private var isShowingPackingListAddSheet: Bool = false
    
    var user: User? = nil
    var lockToProvidedUser: Bool = false
    @State private var selectedUser: User? = nil
    
    var allowCreatingList: Bool = true
    
    var alreadyAppliedLists: [PackingList] {
        if let trip {
            return  trip.alreadyUsedTemplates
        } else {
            return []
        }
    }
    
    var searchResults: [PackingList] {
        if searchText.isEmpty {
            return availableLists
        } else {
            return availableLists.filter { $0.name == (searchText) }
        }
    }
    
    var body: some View {
        VStack {
            if availableLists.isEmpty {
                ContentUnavailableView {
                    Label("No Packing Lists", systemImage: suitcaseIcon)
                } description: {
                    Text("You haven't added any lists to this trip!")
                } actions: {
                    Button("Create Packing List") {
                        isShowingPackingListAddSheet.toggle()
                    }
                }
            } else {
                List {
                    ForEach(searchResults, id: \.id) { packingList in
                        PackingListRowView(packingList: packingList, showUserPill: false, isSelected: packingList == selectedList)
                            .onTapGesture {
                                withAnimation {
                                    selectedList = packingList
                                }
                            }
                    }
                    .listRowBackground(Color(.secondarySystemBackground))
                    
                    Section {
                        Button {
                            isShowingPackingListAddSheet.toggle()
                        } label: {
                            Label("Add New Template", systemImage: defaultPackingListIcon)
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Search For Packing Lists")
        .navigationTitle("Default Packing Lists")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                Menu {
                    UserPickerBaseView(selectedUser: $selectedUser.animation())
                } label: {
                    Image(systemName: "person.circle")
                }
            }
        }
        .sheet(isPresented: $isShowingPackingListAddSheet) {
            PackingListEditView(isTemplate: false, trip: trip, isDeleted: .constant(false))
        }
        .onAppear {
            selectedUser = user
        }
    }
}
