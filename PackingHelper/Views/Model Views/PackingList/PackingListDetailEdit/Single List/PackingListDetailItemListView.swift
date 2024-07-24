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
    
    var shouldShowCount: Bool {
        return packingList.type != .task && packingList.template == false
    }
    
    var body: some View {
        List {
            ForEach(items, id: \.id) { item in
                PackingListDetailEditRowView(
                    packingList: packingList,
                    item: item,
                    showCount: shouldShowCount,
                    showButton: packingList.template == false
                )
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
    }
}
//
//#Preview {
//    PackingListDetailItemListView()
//}
