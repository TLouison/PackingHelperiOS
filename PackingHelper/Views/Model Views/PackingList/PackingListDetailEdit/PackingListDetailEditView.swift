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
    
    @State private var isEditingInPlace = false
    
    var noUnpackedItemString: String {
        if packingList.items?.count ?? 0 == 0 {
            "You haven't added any items to this list yet! Add one below to get started with your packing."
        } else {
            "You've packed all your items on this list. Great work!"
        }
    }
    
    
    var body: some View {
        UnifiedPackingListView(
            lists: [packingList],
            users: [],
            listType: packingList.type,
            title: packingList.name,
            onAddList: nil,
        )
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var lists: [PackingList]
    @Previewable @State var currentView: PackingListDetailViewCurrentSelection = .unpacked
    Text("List Type: \(lists.first!.type) | Default List? \(lists.first!.template)")
    PackingListDetailEditView(packingList: lists.first!, currentView: $currentView)
}
