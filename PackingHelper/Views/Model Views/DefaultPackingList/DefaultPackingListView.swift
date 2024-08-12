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
    
    @State private var selectedUser: User?
    @Query private var users: [User]
    
    @State private var separateByUser: Bool = false
    
    @State private var isShowingDefaultPackingListAddSheet: Bool = false
    @State private var isShowingExplanationSheet: Bool = false
    
    @ViewBuilder func explanationSheet() -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Default Packing Lists")
                    .font(.title)
                    .fontWeight(.semibold)
                Spacer()
                Image(systemName: suitcaseIcon)
                    .imageScale(.large)
                    .foregroundStyle(.accent)
                    .onTapGesture {
                        isShowingExplanationSheet.toggle()
                    }
            }
            .padding(.bottom, 10)
                ScrollView {
                    Text("Packing lists are a convenient way to save lists of items or tasks that you can easily apply to trips. This means you can create a packing list once, and then add those items to any future trip you create.")
                        .padding(.bottom, 10)
                    
                    Text("Create lists for categories such as electronics, toiletries, and clothing, or for travel occasions like vacations, business trips, weddings to make sure you always bring what you need.")
                }
        }
        .padding()
    }
    
    var visiblePackingLists: [PackingList] {
        if let selectedUser {
            return defaultPackingLists.filter{ $0.user == selectedUser }
        } else {
            return defaultPackingLists
        }
    }
    
    var showUserBadges: Bool {
        return selectedUser == nil && separateByUser == false && users.count > 1
    }
    
    @ViewBuilder
    func listOfLists(_ lists: [PackingList]) -> some View {
        ForEach(ListType.allCases, id: \.rawValue) { listType in
            let listsOfType = lists.filter{ $0.type == listType }
            if !listsOfType.isEmpty {
                DefaultPackingViewListTypeSectionView(listType: listType, packingLists: listsOfType, showUserBadge: showUserBadges, showIndent: separateByUser)
                    .listStyle(.insetGrouped)
            }
        }
    }
    
    @ViewBuilder
    var userSeparatedLists: some View {
        List {
            ForEach(users, id: \.id) { user in
                CollapsibleSection {
                    HStack {
                        user.pillIcon
                            .font(.title)
                        
                        Spacer()
                    }
                } content: {
                    listOfLists(PackingList.filtered(user: user, visiblePackingLists))
                }
            }
        }
    }
    
    @ViewBuilder
    var combinedLists: some View {
        List {
            listOfLists(visiblePackingLists)
        }
//        .listStyle(.grouped)
    }
    
    @ViewBuilder
    var listView: some View {
        switch separateByUser {
        case false:
            combinedLists
        case true:
            userSeparatedLists
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if users.count > 1 && !separateByUser {
                    UserPickerView(selectedUser: $selectedUser)
                        .padding(.horizontal)
                }
                
                if !visiblePackingLists.isEmpty {
                    listView
                        .navigationTitle("Packing Lists")
                } else {
                    ContentUnavailableView {
                        Label("No Packing Lists", systemImage: suitcaseIcon)
                    } description: {
                        Text("You haven't created any packing lists! Create one to simplify your trip creation.")
                    } actions: {
                        Button("Create Packing List", systemImage: "folder.badge.plus") {
                            isShowingDefaultPackingListAddSheet.toggle()
                        }
                    }
                }
            }
            .navigationTitle("Packing Lists")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Menu {
                        Button {
                            withAnimation {
                                separateByUser.toggle()
                                selectedUser = nil
                            }
                        } label: {
                            HStack {
                                Text("Separate By User")
                                if separateByUser {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    } label: {
                            Label("Separate By User", systemImage: "person.circle")
                    }
                    Button {
                        isShowingDefaultPackingListAddSheet.toggle()
                    } label: {
                        Image(systemName: "plus.circle")
                    }
                }
                ToolbarItemGroup(placement: .topBarLeading) {
                    Button {
                        isShowingExplanationSheet.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                }
            }
            .sheet(isPresented: $isShowingDefaultPackingListAddSheet) {
                PackingListEditView(isTemplate: true, isDeleted: .constant(false))
            }
            .sheet(isPresented: $isShowingExplanationSheet) {
                explanationSheet()
                    .presentationDetents([.height(300)])
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    DefaultPackingListView()
}
