//
//  DefaultPackingViewListTypeSectionView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI

struct DefaultPackingViewListTypeSectionView: View {
    let listType: ListType
    let packingLists: [PackingList]
    
    var showUserBadge: Bool = false
    
    @State private var isExpanded: Bool = true
    
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
            }
        }
    }
}

//#Preview {
//    DefaultPackingViewListTypeSectionView()
//}
