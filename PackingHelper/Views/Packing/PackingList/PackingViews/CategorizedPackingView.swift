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
                            realIndex = packingList.items.firstIndex(of: packingList.incompleteItems[index])!
                        case false:
                            realIndex = packingList.items.firstIndex(of: packingList.completeItems[index])!
                    }
                    packingList.items.remove(at: realIndex)
                }
            })
        }
    }
    
    var body: some View {
        List {
            if !packingList.incompleteItems.isEmpty {
                packingListSection(items: packingList.incompleteItems, isUnpackedSection: true)
            }
            if !packingList.completeItems.isEmpty {
                packingListSection(items: packingList.completeItems, isUnpackedSection: false)
            }
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
