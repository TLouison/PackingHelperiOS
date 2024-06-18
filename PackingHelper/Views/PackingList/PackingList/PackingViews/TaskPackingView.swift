//
//  TaskPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 11/11/23.
//

import SwiftUI

struct TaskPackingView: View {
    var list: PackingList
    
    var body: some View {
        List {
            ForEach(list.items ?? []) { item in
                PackingListEditSectionRowView(item: item, showCount: false)
                    .strikethrough(item.isPacked)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    if var items = list.items {
                        items.remove(at: index)
                    }
                }
            }
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .scrollContentBackground(.hidden)
    }
}

