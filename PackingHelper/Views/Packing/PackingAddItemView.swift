//
//  PackingAddItemView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/19/23.
//

import SwiftUI

struct PackingAddItemView: View {
    let packingList: PackingList
    
    @State private var packingRecommendation: PackingRecommendationResult = PackingEngine.suggest()
    
    @State private var newItemName = ""
    @State private var newItemCount = 0
    
    var body: some View {
        VStack {
            if newItemName != "" {
                PackingRecommendationView(recommendation: packingRecommendation)
                    .transition(.pushAndPull(.bottom).animation(.easeInOut))
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
}
