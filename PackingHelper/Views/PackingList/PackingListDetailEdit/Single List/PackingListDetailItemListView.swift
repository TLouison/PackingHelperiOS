//
//  PackingListDetailItemListView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/20/24.
//

import SwiftUI

struct PackingListDetailItemListView: View {
    let packingList: PackingList
    var items: [Item]
    
    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                PackingListDetailEditRowView(
                    item: item,
                    showCount: packingList.type != .task,
                    showButton: packingList.template == false
                )
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    packingList.removeItem(at: index)
                }
            })
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
//
//#Preview {
//    PackingListDetailItemListView()
//}
