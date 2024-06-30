//
//  AddItemForGroupView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/28/24.
//

import SwiftUI
import SwiftData

struct PackingAddItemForGroupView: View {
    @Binding var selectedPackingList: PackingList?
    let availableLists: [PackingList]
    
    let currentView: PackingListDetailViewCurrentSelection
    
    var body: some View {
        VStack {
            HStack {
                Text("Adding new item to").font(.headline)
                Picker("Packing List", selection: $selectedPackingList) {
                    ForEach(availableLists, id: \.id) { list in
                        Text(list.name).tag(list)
                    }
                }
            }
            .font(.title)
            .padding(.horizontal)
            
            PackingAddItemView(packingList: selectedPackingList!, newItemIsPacked: currentView == .packed)
        }
        .padding(.bottom)
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var packingLists: [PackingList]
    PackingAddItemForGroupView(selectedPackingList: .constant(packingLists.first!), availableLists: packingLists, currentView: .unpacked)
}
