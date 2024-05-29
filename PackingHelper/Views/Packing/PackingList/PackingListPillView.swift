//
//  PackingListPillView.swift
//  PackingHelper
//
//  Created by Todd Louison on 5/28/24.
//

import SwiftUI

struct PackingListPillView: View {
    var packingLists: [PackingList] = []
    
    var body: some View {
        if !packingLists.isEmpty {
            ViewThatFits {
                HStack {
                    ForEach(packingLists, id: \.self) { packingList in
                        ZStack {
                            Text(packingList.name)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().foregroundStyle(.accent.opacity(0.7)))
                        }
                    }
                }
                
                LazyVGrid(columns: [GridItem(.flexible()),GridItem(.flexible()), GridItem(.flexible())]) {
                    ForEach(packingLists, id: \.self) { packingList in
                        ZStack {
                            Text(packingList.name)
                                .font(.caption)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(Capsule().foregroundStyle(.accent))
                                .fixedSize(horizontal: true, vertical: /*@START_MENU_TOKEN@*/true/*@END_MENU_TOKEN@*/)
                        }
                    }
                }
            }
            
        }
    }
}

#Preview {
    PackingListPillView()
}
