//
//  UncategorizedPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 11/3/23.
//

import SwiftUI

struct UncategorizedPackingView: View {
    var packingList: PackingList
    
    var body: some View {
        List {
            ForEach(packingList.items ?? []) { item in
                if packingList.template {
                    if packingList.type == .task {
                        PackingListDetailEditRowView(item: item, showCount: false, showButton: false)
                    } else {
                        PackingListDetailEditRowView(item: item, showButton: false)
                    }
                } else {
                    if packingList.type == .task {
                        PackingListDetailEditRowView(item: item, showCount: false).strikethrough(item.isPacked)
                    } else {
                        PackingListDetailEditRowView(item: item)
                                .strikethrough(item.isPacked)
                    }
                }
            }
            .onDelete { indexSet in
                for index in indexSet {
                    packingList.removeItem(at: index)
                }
            }
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .scrollContentBackground(.hidden)
    }
}
