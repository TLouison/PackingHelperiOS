//
//  PackingListMultiListEditView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI
import SwiftData

struct PackingListMultiListEditView: View {
    @Bindable var packingList: PackingList
    
    @Binding var currentView: PackingListDetailViewCurrentSelection
    
    @Binding var isAddingNewItem: Bool
    @Binding var listToAddTo: PackingList?
    
    var currentItems: [Item] {
        if currentView == .unpacked {
            packingList.incompleteItems
        } else {
            packingList.completeItems
        }
    }
    
    var body: some View {
        ForEach(currentItems, id: \.id) { item in
            PackingListDetailEditRowView(
                packingList: packingList,
                item: item,
                showCount: packingList.type != .task,
                showButton: packingList.template == false
            )
        }
        
        if currentView == .unpacked {
            VStack(alignment: .center) {
                Button {
                    withAnimation {
                        listToAddTo = packingList
                        isAddingNewItem.toggle()
                    }
                } label: {
                    Label("Add Item", systemImage: "plus.circle.fill")
                }
            }
        }
    }
}
