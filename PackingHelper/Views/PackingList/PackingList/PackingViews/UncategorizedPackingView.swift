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
                        PackingListEditSectionRowView(item: item, showCount: false, showButton: false)
                    } else {
                        PackingListEditSectionRowView(item: item, showButton: false)
                    }
                } else {
                    if packingList.type == .task {
                        PackingListEditSectionRowView(item: item, showCount: false).strikethrough(item.isPacked)
                    } else {
                        PackingListEditSectionRowView(item: item)
                                .strikethrough(item.isPacked)
                    }
                }
            }
            .onDelete { indexSet in
                if var items = packingList.items {
                    for index in indexSet {
                        items.remove(at: index)
                    }
                }
            }
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .scrollContentBackground(.hidden)
    }
}
