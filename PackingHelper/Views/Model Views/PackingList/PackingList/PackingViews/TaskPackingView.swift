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
                PackingListDetailEditRowView(item: item, showCount: false)
                    .strikethrough(item.isPacked)
            }
            .onDelete { indexSet in
                for index in indexSet {
                    list.removeItem(at: index)
                }
            }
            .listRowBackground(Color(.secondarySystemBackground))
        }
        .scrollContentBackground(.hidden)
    }
}

