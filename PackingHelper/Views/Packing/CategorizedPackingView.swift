//
//  CategorizedPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/21/23.
//

import SwiftUI

struct CategorizedPackingView: View {
    let packingList: PackingList
    
    @ViewBuilder
    func packingListSection(items: [Item], isUnpackedSection: Bool) -> some View {
        Section(isUnpackedSection ? "Unpacked" : "Packed") {
            ForEach(items) { item in
                PackingListEditSectionRowView(item: item)
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let realIndex: Int
                    switch isUnpackedSection {
                        case true:
                            realIndex = packingList.items.firstIndex(of: packingList.unpackedItems[index])!
                        case false:
                            realIndex = packingList.items.firstIndex(of: packingList.packedItems[index])!
                    }
                    packingList.items.remove(at: realIndex)
                }
            })
        }
    }
    
    var body: some View {
        List {
            if !packingList.unpackedItems.isEmpty {
                packingListSection(items: packingList.unpackedItems, isUnpackedSection: true)
            }
            if !packingList.packedItems.isEmpty {
                packingListSection(items: packingList.packedItems, isUnpackedSection: false)
            }
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
