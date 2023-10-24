//
//  TripPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI


struct PackingListEditView: View {
    var packingList: PackingList
    var isDayOf: Bool = false
    
    var visibleItems: [Item] {
        if self.isDayOf {
            return packingList.dayOfItems
        } else {
            return packingList.items.filter{ $0.type != .dayOf }
        }
    }
    
    var pageTitle: String {
        switch isDayOf {
        case true: return "Day-Of Packing List"
        case false: return packingList.nameString
        }
    }
    
    var body: some View {
        VStack {
            if packingList.items.isEmpty {
                ContentUnavailableView {
                    Label("No Items On List", systemImage: "bag")
                } description: {
                    Text("You haven't added any items to your list. Add one now to track your packing!")
                }
            } else {
                if packingList.template || isDayOf {
                    List {
                        ForEach(visibleItems) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("\(item.count)")
                            }
                        }
                        .onDelete { indexSet in
                            for index in indexSet {
                                packingList.deleteItem(visibleItems[index])
                            }
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                    }
                    .scrollContentBackground(.hidden)
                } else {
                    CategorizedPackingView(packingList: packingList)
                }
            }
            
            Spacer()
            
            PackingAddItemView(packingList: packingList, isDayOf: isDayOf)
        }
        .navigationTitle(pageTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}

//#Preview {
//    TripPackingView()
//}
