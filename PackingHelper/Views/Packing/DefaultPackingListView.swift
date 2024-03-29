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

    @Query(
        filter: #Predicate<PackingList> {$0.template == true},
        sort: [SortDescriptor(\.name)],
        animation: .snappy
    )
    var defaultPackingLists: [PackingList]
    
    @State private var isShowingDefaultPackingListAddSheet: Bool = false
    @State private var isShowingExplanationSheet: Bool = false
    
    @ViewBuilder func explanationSheet() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Default Packing Lists")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: "suitcase.cart")
                    .imageScale(.large)
                    .foregroundStyle(.accent)
                    .onTapGesture {
                        isShowingExplanationSheet.toggle()
                    }
            }
            .padding(.bottom, 10)
                ScrollView {
                    Text("Default packing lists are a convenient way to save lists of items or tasks that you can easily apply to trips. This means you can create a packing list once, and then add those items to any future trip you create.")
                        .padding(.bottom, 10)
                    
                    Text("Create lists for vacations, business trips, weddings, or any other occasion you can think of to make sure you always bring what you need.")
                }
        }
        .padding()
    }
    
    var body: some View {
            VStack {
                if !defaultPackingLists.isEmpty {
                    List {
                        ForEach(defaultPackingLists) { packingList in
                            NavigationLink {
                                PackingListDetailView(packingList: packingList)
                                    .padding(.vertical)
                            } label: {
                                Label(packingList.name, systemImage: packingList.icon)
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
                            isShowingDefaultPackingListAddSheet.toggle()
                        }
                    }
                }
            }
            .navigationTitle("Default Packing Lists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button {
                        isShowingExplanationSheet.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    Button {
                        isShowingDefaultPackingListAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowingDefaultPackingListAddSheet) {
                PackingListEditView(isTemplate: true, isDeleted: .constant(false))
                    .presentationDetents([.height(225)])
            }
            .sheet(isPresented: $isShowingExplanationSheet) {
                explanationSheet()
                    .presentationDetents([.height(300)])
            }
    }
}
//
//#Preview {
//    DefaultPackingListView()
//}
