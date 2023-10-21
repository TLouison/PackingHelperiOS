//
//  DefaultPackingListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/20/23.
//

import SwiftUI
import SwiftData

struct DefaultPackingListView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query(FetchDescriptor(
        predicate: #Predicate<PackingList>{ $0.template == true },
        sortBy: [SortDescriptor(\.created, order: .reverse)]
    ),
           animation: .snappy
    ) var defaultPackingLists: [PackingList]
    
    @State private var isShowingDefaultPackingListAddSheet: Bool = false
    
    var body: some View {
            VStack {
                if !defaultPackingLists.isEmpty {
                    List {
                        ForEach(defaultPackingLists) { packingList in
                            NavigationLink {
                                PackingListEditView(packingList: packingList)
                                    .padding(.vertical)
                            } label: {
                                Label(packingList.nameString, systemImage: "suitcase.rolling.fill")
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                modelContext.delete(defaultPackingLists[index])
                            }
                        }
                    }
                    .navigationTitle("Default Packing Lists")
                } else {
                    ContentUnavailableView {
                        Label("No Default Packing Lists", systemImage: "suitcase.rolling.fill")
                    } description: {
                        Text("You haven't created any default packing lists! Create one to simplify your trip creation.")
                    } actions: {
                        Button("Create Default Packing List", systemImage: "folder.badge.plus") {
                            let newPackingList = PackingList(template: true, name: "Default")
                            modelContext.insert(newPackingList)
                        }
                    }
                }
            }
            .navigationTitle("Default Packing Lists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingDefaultPackingListAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowingDefaultPackingListAddSheet) {
                DefaultPackingListAddSheet()
                    .presentationDetents([.height(200)])
            }
    }
}
//
//#Preview {
//    DefaultPackingListView()
//}
