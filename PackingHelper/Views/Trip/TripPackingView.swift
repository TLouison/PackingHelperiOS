//
//  TripPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI

struct TripPackingView: View {
    @Bindable var packingList: PackingList
    
    @State private var newItemName: String = ""
    @State private var newItemCount: Int = 1
    @State private var packingRecommendation: PackingRecommendationResult = PackingEngine.suggest()
    
    var unpackedItems: [Item] {
        packingList.items.filter { $0.packed == false }
    }
    
    var packedItems: [Item] {
        packingList.items.filter { $0.packed == true }
    }
    
    var body: some View {
        VStack {
            List {
                Section("Unpacked") {
                    ForEach(unpackedItems) { item in
                        HStack {
                            Image(systemName: item.packed ? Symbol.packed.name : Symbol.unpacked.name)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .offset(x: item.packed ? 0 : -2)
                                .symbolRenderingMode(.multicolor)
                                .foregroundStyle(item.packed ? .green : .secondary)
                                .onTapGesture {
                                    item.packed.toggle()
                                }
                                .contentTransition(.symbolEffect(.replace))
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.trailing)
                            
                            Group {
                                Text(item.name).font(.title)
                                Spacer()
                                Text(String(item.count)).font(.largeTitle).bold()
                            }
                            .strikethrough(item.packed)
                        }
                    }
                    .onDelete(perform: { indexSet in
                        for index in indexSet {
                            packingList.items.remove(at: index)
                        }
                    })
                }
                Section("Packed") {
                    ForEach(packedItems) { item in
                        HStack {
                            Image(systemName: item.packed ? Symbol.packed.name : Symbol.unpacked.name)
                                .resizable()
                                .frame(width: 30, height: 30)
                                .offset(x: item.packed ? 0 : -2)
                                .symbolRenderingMode(.multicolor)
                                .foregroundStyle(item.packed ? .green : .secondary)
                                .onTapGesture {
                                    item.packed.toggle()
                                }
                                .contentTransition(.symbolEffect(.replace))
                                .padding()
                                .background(Color(.secondarySystemBackground))
                                .clipShape(RoundedRectangle(cornerRadius: 16))
                                .padding(.trailing)
                            
                            Group {
                                Text(item.name).font(.title)
                                Spacer()
                                Text(String(item.count)).font(.largeTitle).bold()
                            }
                            .strikethrough(item.packed)
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
            .listStyle(.plain)
            
            Spacer()
            
            VStack {
                HStack {
                    TextField("Item Name", text: $newItemName)
                        .padding()
                        .onChange(of: newItemName) {
                            packingRecommendation = PackingEngine.suggest()
                        }
                    Spacer()
                    TextField("Count", value: $newItemCount, format: .number)
                        .keyboardType(.numberPad)
                        .background(Color(.tertiarySystemBackground))
                        .frame(maxWidth: 40)
//                        .onReceive(Just(newItemCount)) { newValue in
//                            let filtered = newValue.filter { "0123456789".contains($0) }
//                            if filtered != newValue {
//                                self.newItemCount = filtered
//                            }
//                        }
                }
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))
                
                if newItemName != "" {
                    PackingRecommendationView(recommendation: packingRecommendation)
                        .transition(.pushAndPull(.leading).animation(.easeInOut))
                        .onAppear {
                            packingRecommendation = PackingEngine.suggest()
                        }
                        .onTapGesture {
                            packingList.items.append(
                                Item(name: packingRecommendation.item, count: packingRecommendation.count)
                            )
                            self.newItemName = ""
                        }
                }
                
                Button("Add Item") {
                    if newItemName != "" {
                        packingList.items.append(Item(name: newItemName, count: newItemCount))
                    }
                }
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
    }
    
    enum Symbol: Hashable, CaseIterable {
       case packed, unpacked

       var name: String {
           switch self {
               case .packed: return "bag.fill"
               case .unpacked: return "bag.badge.plus"
           }
       }
   }
}

//#Preview {
//    TripPackingView()
//}
