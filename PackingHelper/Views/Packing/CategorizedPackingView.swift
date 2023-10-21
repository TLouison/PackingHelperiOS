//
//  CategorizedPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/21/23.
//

import SwiftUI

fileprivate enum Symbol: Hashable, CaseIterable {
    case packed, unpacked

    var name: String {
        switch self {
            case .packed: return "suitcase.rolling.fill"
            case .unpacked: return "suitcase.rolling"
        }
    }
}

struct CategorizedPackingView: View {
    let packingList: PackingList
    
    @ViewBuilder
    func itemCheckbox(_ item: Item) -> some View {
        Image(systemName: item.isPacked ? Symbol.packed.name : Symbol.unpacked.name)
            .resizable()
            .frame(width: 30, height: 30)
            .offset(x: item.type == .packed ? 0 : -2)
            .symbolRenderingMode(.multicolor)
            .foregroundStyle(item.isPacked ? .green : .secondary)
            .onTapGesture {
                withAnimation {
                    packingList.togglePacked(item)
                }
            }
            .contentTransition(.symbolEffect(.replace))
            .padding()
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .padding(.trailing)
    }
    
    var body: some View {
        List {
            Section("Unpacked") {
                ForEach(packingList.unpackedItems) { item in
                    HStack {
                        itemCheckbox(item)
                        
                        Group {
                            Text(item.name).font(.title)
                            Spacer()
                            Text(String(item.count)).font(.largeTitle).bold()
                        }
                        .strikethrough(item.isPacked)
                    }
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        packingList.items.remove(at: index)
                    }
                })
            }
            Section("Packed") {
                ForEach(packingList.packedItems) { item in
                    HStack {
                        itemCheckbox(item)
                        
                        Group {
                            Text(item.name).font(.title)
                            Spacer()
                            Text(String(item.count)).font(.largeTitle).bold()
                        }
                        .strikethrough(item.isPacked)
                    }
                    .transition(.scale)
                    
                }
                .onDelete(perform: { indexSet in
                    for index in indexSet {
                        packingList.items.remove(at: index)
                    }
                })
            }
        }
        .listStyle(.grouped)
    }
}

//#Preview {
//    CategorizedPackingView()
//}
