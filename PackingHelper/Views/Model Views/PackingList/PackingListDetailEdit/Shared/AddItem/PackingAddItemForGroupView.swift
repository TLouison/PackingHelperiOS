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
            if selectedPackingList == nil {
                Label("Please select a list to continue.", systemImage: "exclamationmark.triangle.fill")
                    .background(.yellow.opacity(0.2))
                    .roundedBox()
            }
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
            
            if let selectedPackingList {
                PackingAddItemView(packingList: selectedPackingList, newItemIsPacked: currentView == .packed)
            }
        }
        .padding(.bottom)
    }
}

//@available(iOS 18, *)
//#Preview(traits: .sampleData) {
//    @Previewable @Query var packingLists: [PackingList]
//    PackingAddItemForGroupView(selectedPackingList: packingLists.first!, availableLists: packingLists, currentView: .unpacked)
//}
