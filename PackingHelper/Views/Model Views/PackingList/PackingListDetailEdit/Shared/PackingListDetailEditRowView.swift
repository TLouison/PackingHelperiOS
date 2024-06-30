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

struct PackingListDetailEditRowView: View {
    let packingList: PackingList
    @Bindable var item: Item
    var showCount: Bool = true
    var showButton: Bool = true
    
    @State private var isShowingItemEditSheet = false
    
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
            Text(item.name).font(.headline)
            
            if showCount {
                Divider()
                Text(String(item.count))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .bold()
            }
            
            Spacer()
            
            if showButton {
                itemCheckbox(item)
                    .onTapGesture {
                        // Only allow toggle if the list is actually being used for packing
                        if showButton {
                            withAnimation {
                                item.isPacked.toggle()
                            }
                        }
                    }
            }
        }
        .contentShape(.rect)
        .swipeActions {
            Button(role: .destructive) {
                packingList.removeItem(item)
            } label: {
                Label("Remove", systemImage: "trash")
                    .labelStyle(.iconOnly)
                    .tint(.red)
            }
            
            Button {
                isShowingItemEditSheet = true
            } label: {
                Label("Edit", systemImage: "pencil")
                    .labelStyle(.iconOnly)
                    .tint(.yellow)
            }
        }
        .sheet(isPresented: $isShowingItemEditSheet) {
            EditItemView(item: item)
                .padding(.horizontal)
                .presentationDetents([.height(200)])
        }
        .fixedSize(horizontal: false, vertical: true)
    }
}

