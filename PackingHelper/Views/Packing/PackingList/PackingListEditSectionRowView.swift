//
//  PackingListEditSection.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/22/23.
//

import SwiftUI

fileprivate enum Symbol: Hashable, CaseIterable {
    case packed, unpacked

    var name: String {
        switch self {
            case .packed: return "minus.circle.fill"
            case .unpacked: return "plus.circle.fill"
        }
    }
}

struct PackingListEditSectionRowView: View {
    let item: Item
    var showCount: Bool = true
    var showButton: Bool = true
    
    @ViewBuilder
    func itemCheckbox(_ item: Item) -> some View {
        Image(systemName: item.isPacked ? Symbol.packed.name : Symbol.unpacked.name)
            .resizable()
            .imageScale(.large)
            .frame(width: 20, height: 20)
            .symbolRenderingMode(.multicolor)
            .contentTransition(.symbolEffect(.replace))
    }
    
    var body: some View {
        HStack {
            if showButton {
                itemCheckbox(item)
            }
            
            Text(item.name).font(.headline)
            
            if showCount {
                Spacer()
                Text(String(item.count)).font(.subheadline).bold()
            }
        }
        .contentShape(.rect)
        .onTapGesture {
            withAnimation {
                item.isPacked.toggle()
            }
        }
    }
}

