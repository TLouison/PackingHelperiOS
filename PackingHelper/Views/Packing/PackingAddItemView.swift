//
//  PackingAddItemView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/19/23.
//

import SwiftUI

struct PackingAddItemView: View {
    let packingList: PackingList
    let isDayOf: Bool
    
    @State private var packingRecommendation: PackingRecommendationResult = PackingEngine.suggest()
    
    @State private var newItemName = ""
    @State private var newItemCount = 0
    
    var body: some View {
        VStack {
            if newItemName != "" && FeatureFlags.showingRecommendations {
                PackingRecommendationView(recommendation: packingRecommendation)
                    .onAppear {
                        packingRecommendation = PackingEngine.suggest()
                    }
                    .onTapGesture {
                        packingList.items.append(
                            Item(name: packingRecommendation.item, count: packingRecommendation.count, isPacked: false, type: isDayOf ? .dayOf : .regular)
                        )
                        self.newItemName = ""
                        self.newItemCount = 1
                    }
                    .transition(.pushAndPull(.bottom))
            }
            
            HStack {
                TextField("Item Name", text: $newItemName)
                    .padding()
                    .onChange(of: newItemName) {
                        packingRecommendation = PackingEngine.suggest()
                    }
                Spacer()
                Divider()
                Picker("Count", selection: $newItemCount) {
                    ForEach(1..<100) { val in
                        Text("\(val)").tag(val)
                    }
                }
                .pickerStyle(.wheel)
                .frame(maxWidth: 60, maxHeight: 60)
                .padding(.trailing, 10)
            }
            .frame(maxHeight: 60)
            .background(.thickMaterial)
            .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
            
            Button("Add Item") {
                if newItemName != "" {
                    let newItem = Item(name: newItemName, count: newItemCount, isPacked: false, type: isDayOf ? .dayOf : .regular)
                    packingList.items.append(newItem)
                    newItemName = ""
                    newItemCount = 1
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
        }
        .padding(.horizontal)
    }
}
