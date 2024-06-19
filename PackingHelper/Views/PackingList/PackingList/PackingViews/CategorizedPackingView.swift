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
    func packingListSection(items: [Item], title: String, isUnpackedSection: Bool) -> some View {
        Section(title) {
            ForEach(items) { item in
                PackingListEditSectionRowView(item: item)
            }
            .onDelete(perform: { indexSet in
                for index in indexSet {
                    let realIndex: Int
                    switch isUnpackedSection {
                    case true:
                        realIndex = items.firstIndex(of: items[index])!
                    case false:
                        realIndex = items.firstIndex(of: items[index])!
                    }
                    packingList.removeItem(at: realIndex)
                }
            })
        }
    }
    
    var body: some View {
        List {
            if !packingList.incompleteItems.isEmpty {
                ForEach(PackingRecommendationCategory.allCases, id: \.rawValue) { category in
                    let visibleItems = packingList.incompleteItems.filter { $0.category == category.rawValue }
                    if !visibleItems.isEmpty {
                        packingListSection(
                            items: visibleItems,
                            title: category.rawValue.uppercased(),
                            isUnpackedSection: true
                        )
                    }
                }
            }
            if !packingList.completeItems.isEmpty {
                packingListSection(items: packingList.completeItems, title: "Packed", isUnpackedSection: false)
            }
        }
        .listStyle(.grouped)
        .scrollContentBackground(.hidden)
    }
}
