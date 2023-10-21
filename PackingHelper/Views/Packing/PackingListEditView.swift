//
//  TripPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI


struct PackingListEditView: View {
    var packingList: PackingList
    
    var body: some View {
        VStack {
            if packingList.items.isEmpty {
                ContentUnavailableView {
                    Label("No Items On List", systemImage: "bag")
                } description: {
                    Text("You haven't added any items to your list. Add one now to track your packing!")
                }
            } else {
                if packingList.template {
                    List {
                        ForEach(packingList.items) { item in
                            HStack {
                                Text(item.name)
                                Spacer()
                                Text("\(item.count)")
                            }
                        }
                    }
                } else {
                    CategorizedPackingView(packingList: packingList)
                }
            }
        }
        .navigationTitle(packingList.nameString)
        .navigationBarTitleDisplayMode(.inline)
        .overlay(alignment: .bottom) {
            PackingAddItemView(packingList: packingList)
        }
    }
}

//#Preview {
//    TripPackingView()
//}
