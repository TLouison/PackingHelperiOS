//
//  TripPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI


struct TripPackingView: View {
    @Binding var packingList: PackingList
    
    @State private var newItemName: String = ""
    @State private var newItemCount: Int = 1
    @State private var packingRecommendation: PackingRecommendationResult = PackingEngine.suggest()
    
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
        VStack {
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
            
            Spacer()
            
            VStack {
                HStack {
                    TextField("Item Name", text: $newItemName)
                        .padding()
                        .onChange(of: newItemName) {
                            packingRecommendation = PackingEngine.suggest()
                        }
                    Spacer()
                    Divider()
                    TextField("Count", value: $newItemCount, format: .number)
                        .font(.largeTitle)
                        .keyboardType(.numberPad)
                        .frame(maxWidth: 40)
                        .padding()
//                        .onReceive(Just(newItemCount)) { newValue in
//                            let filtered = newValue.filter { "0123456789".contains($0) }
//                            if filtered != newValue {
//                                self.newItemCount = filtered
//                            }
//                        }
                }
                .frame(maxHeight: 60)
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
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal)
        }
        .navigationTitle("Packing List")
        .navigationBarTitleDisplayMode(.inline)
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
