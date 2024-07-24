//
//  PackingListRowView.swift
//  PackingHelper
//
//  Created by Todd Louison on 7/20/24.
//

import SwiftUI
import SwiftData

struct PackingListRowView: View {
    let packingList: PackingList
    
    var showUserPill: Bool = false
    
    var body: some View {
        HStack {
                Text(packingList.name)
                
                if showUserPill {
                    packingList.user?.pillIcon
                }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var packingLists: [PackingList]
    PackingListRowView(packingList: packingLists.first!)
}
