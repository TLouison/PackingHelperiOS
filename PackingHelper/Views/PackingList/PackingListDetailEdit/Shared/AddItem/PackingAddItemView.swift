//
//  PackingAddItemView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/19/23.
//

import SwiftUI
import SwiftData

struct PackingAddItemView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    @FocusState private var nameIsFocused: Bool
    
    let packingList: PackingList
    
    @State private var packingRecommendation: PackingRecommendationResult = PackingEngine.suggest()
    
    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var newItemCategory: PackingRecommendationCategory?
    
    var formIsValid: Bool {
        return newItemName != "" && newItemCount > 0 && newItemCategory != nil
    }
    
    var body: some View {
        VStack(spacing: 10) {
//            if newItemName != "" && FeatureFlags.showingRecommendations {
//                PackingRecommendationView(recommendation: packingRecommendation)
//                    .onAppear {
//                        packingRecommendation = PackingEngine.suggest()
//                    }
//                    .onTapGesture {
//                        packingList.items.append(
//                            Item(name: packingRecommendation.item, count: packingRecommendation.count, isPacked: false)
//                        )
//                        self.newItemName = ""
//                        self.newItemCount = 1
//                    }
//                    .transition(.pushAndPull(.bottom))
//            }
            
            VStack {
                HStack {
                    TextField("Item Name", text: $newItemName)
                        .padding()
                        .onChange(of: newItemName) {
                            if !newItemName.isEmpty {
                                let categoryRecommendation = PackingEngine.interpretItem(itemName: newItemName)
                                newItemCategory = categoryRecommendation
                            } else {
                                newItemCategory = nil
                            }
                        }
                        .submitLabel(.done)
                        .keyboardType(.default)
                        .focused($nameIsFocused)
                        .onSubmit {
                            // If the done button is pressed, close out everything
                            addItem()
                            dismiss()
                        }
                        .onAppear {
                            self.nameIsFocused = true
                        }
                    
                    if packingList.type != .task {
                        Spacer()
                        Divider()
                        Picker("Count", selection: $newItemCount) {
                            ForEach(1..<100) { val in
                                Text("\(val)").tag(val)
                            }
                        }
                        .pickerStyle(.wheel)
                        .buttonStyle(.borderless)
                        .frame(maxWidth: 60, maxHeight: 60)
                        .padding(.trailing, 10)
                    }
                }
                .frame(maxHeight: 55)
                .background(.thickMaterial)
                .rounded()
                
//                Menu(newItemCategory?.rawValue ?? "Select Category") {
//                    ForEach(PackingRecommendationCategory.allCases, id: \.rawValue) { category in
//                        Button {
//                            newItemCategory = category
//                        } label: {
//                            Text(category.rawValue)
//                        }
//                    }
//                }
//                .padding([.horizontal, .top], 5)
//                .frame(maxWidth: .infinity)
//                .background(.thickMaterial)
//                .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
//                .padding([.horizontal, .bottom], 10)
            }
            .rounded()
//            .shaded()
            
            HStack {
                Button("Add Item") {
                    addItem()
                }
                .padding()
                .frame(maxWidth: .infinity)
                .background(.thinMaterial)
                .rounded()
            }
//            .shaded()
        }
        .toolbar(.hidden, for: .tabBar)
        .padding(.horizontal)
    }
    
    func addItem() {
        if newItemName != "" {
            if packingList.type == .task {
                newItemCategory = .Task
            } else {
                if newItemCategory == nil {
                    newItemCategory = PackingEngine.interpretItem(itemName: newItemName)
                }
            }
            
            withAnimation {
                let newItem = Item(name: newItemName, category: newItemCategory!.rawValue.capitalized, count: newItemCount, isPacked: false)
                newItem.list = packingList
                
                packingList.addItem(newItem)
                modelContext.insert(newItem)
                
                newItemName = ""
                newItemCount = 1
            }
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var lists: [PackingList]
    PackingAddItemView(packingList: lists.first!)
}
