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
    
    @ViewBuilder
    func packingListSection(items: [Item], title: String, isUnpackedSection: Bool) -> some View {
        Section(title) {
            ForEach(items) { item in
                PackingListDetailEditRowView(item: item)
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
        VStack {
            if currentView == .unpacked {
                if packingList.incompleteItems.isEmpty {
                    ContentUnavailableView("No Unpacked Items", systemImage: "suitcase", description: Text(noUnpackedItemString))
                } else {
                    List {
                        if currentView == .unpacked && !packingList.incompleteItems.isEmpty {
                            ForEach(packingList.incompleteItems, id: \.id) { item in
                                PackingListDetailEditRowView(
                                    item: item,
                                    showCount: packingList.type != .task,
                                    showButton: packingList.template == false
                                )
                            }
                            .onDelete(perform: { indexSet in
                                for index in indexSet {
                                    packingList.removeItem(at: index)
                                }
                            })
                        }
                    }
                    .listStyle(.grouped)
                    .scrollContentBackground(.hidden)
                }
            } else if currentView == .packed {
                if packingList.completeItems.isEmpty {
                    ContentUnavailableView("No Packed Items", systemImage: "suitcase.fill", description: Text("You haven't packed any items on this list yet!"))
                } else {
                    List {
                        packingListSection(items: packingList.completeItems, title: "Packed", isUnpackedSection: false)
                    }
                    .listStyle(.grouped)
                    .scrollContentBackground(.hidden)
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
