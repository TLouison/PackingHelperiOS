//
//  PackingListDetailEditView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/20/24.
//

import SwiftUI
import SwiftData

struct PackingListDetailEditView: View {
    @Bindable var packingList: PackingList
    
    @Binding var currentView: PackingListDetailViewCurrentSelection
    
    var noUnpackedItemString: String {
        if packingList.items?.count ?? 0 == 0 {
            "You haven't added any items to this list yet! Add one below to get started with your packing."
        } else {
            "You've packed all your items on this list. Great work!"
        }
    }
    
    
    var body: some View {
        VStack {
            if currentView == .unpacked {
                if packingList.incompleteItems.isEmpty {
                    ContentUnavailableView("No Unpacked Items", systemImage: "suitcase", description: Text(noUnpackedItemString))
                } else {
                    PackingListDetailItemListView(packingList: packingList, items: packingList.incompleteItems)
                }
            } else if currentView == .packed {
                if packingList.completeItems.isEmpty {
                    ContentUnavailableView("No Packed Items", systemImage: suitcaseIcon, description: Text("You haven't packed any items on this list yet!"))
                } else {
                    PackingListDetailItemListView(packingList: packingList, items: packingList.completeItems)
                }
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var lists: [PackingList]
    @Previewable @State var currentView: PackingListDetailViewCurrentSelection = .unpacked
    Text("List Type: \(lists.first!.type) | Default List? \(lists.first!.template)")
    PackingListDetailEditView(packingList: lists.first!, currentView: $currentView)
}
