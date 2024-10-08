//
//  PackingAddItemView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/19/23.
//

import SwiftUI
import SwiftData

struct PackingAddItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @FocusState private var nameIsFocused: Bool

    let packingList: PackingList
    var newItemIsPacked: Bool = false

    @State private var packingRecommendation: PackingRecommendationResult = PackingEngine.suggest()

    @State private var newItemName = ""
    @State private var newItemCount = 1
    @State private var newItemCategory: PackingRecommendationCategory?

    var formIsValid: Bool {
        return newItemName != "" && newItemCount > 0 && newItemCategory != nil
    }

    var showCount: Bool {
        packingList.type != .task && packingList.template == false
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

                    if showCount {
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

            HStack {
                Button {
                    addItem()
                } label: {
                    Label("Add Item", systemImage: "plus.circle.fill")
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(.thinMaterial)
                        .rounded()
                        .contentShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
                }
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .padding(.horizontal)
    }

    func addItem() {
        if newItemName != "" {
            withAnimation {
                Item.create(for: packingList, in: modelContext, category: newItemCategory, name: newItemName, count: newItemCount, isPacked: newItemIsPacked)

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
