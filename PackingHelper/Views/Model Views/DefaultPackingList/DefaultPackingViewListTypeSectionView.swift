//
//  DefaultPackingViewListTypeSectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI

struct DefaultPackingViewListTypeSectionView: View {
    @Environment(\.modelContext) private var modelContext
    
    let listType: ListType
    let packingLists: [PackingList]
    
    var showUserBadge: Bool = false
    
    @State private var isShowingDeleteConfirmation: Bool = false
    @State private var listToDelete: PackingList? = nil
    
    var listsOfType: [PackingList] {
        packingLists.filter({$0.type == listType})
    }
    
    var body: some View {
        CollapsibleSection {
            Text("\(listType.rawValue) | \(listsOfType.count)")
        } content: {
            ForEach(listsOfType, id: \.id) { packingList in
                NavigationLink {
                    PackingListDetailView(packingList: packingList)
                        .padding(.vertical)
                } label: {
                    HStack {
                        Label(packingList.name, systemImage: packingList.icon)
                        
                        if showUserBadge {
                            if let user = packingList.user {
                                user.pillIcon
                            }
                        }
                    }
                }
                .swipeActions {
                    // Not setting role = .destructive so item doesn't disappear before deleting
                    Button {
                        listToDelete = packingList
                        isShowingDeleteConfirmation.toggle()
                    } label: {
                        Label("Delete", systemImage: "trash")
                            .tint(.red)
                    }
                }
            }
        }
        .alert("Delete \(listToDelete?.name ?? "default packing List")?", isPresented: $isShowingDeleteConfirmation) {
            Button("Yes, delete \(listToDelete?.name ?? "list")", role: .destructive) {
                if let listToDelete {
                    PackingList.delete(listToDelete, from: modelContext)
                }
                listToDelete = nil
            }
        }
    }
}

//#Preview {
//    DefaultPackingViewListTypeSectionView()
//}
