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
    
    @State private var isExpanded: Bool = true
    
    var listsOfType: [PackingList] {
        packingLists.filter({$0.type == listType})
    }
    
    var body: some View {
        CollapsibleSection(title: "\(listType.rawValue) | \(listsOfType.count)") {
            ForEach(listsOfType, id: \.id) { packingList in
                NavigationLink {
                    PackingListDetailView(packingList: packingList)
                        .padding(.vertical)
                } label: {
                    Label(packingList.name, systemImage: packingList.icon)
                }
            }
        }
    }
}

//#Preview {
//    DefaultPackingViewListTypeSectionView()
//}
