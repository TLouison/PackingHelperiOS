//
//  TripPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI
import SwiftData

enum PackingListDetailViewCurrentSelection: CaseIterable, Codable, Hashable, Sendable {
    case unpacked, packed
}

struct PackingListDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var packingList: PackingList

    @State private var currentView: PackingListDetailViewCurrentSelection = .unpacked
    @State private var isShowingListSettings: Bool = false
    @State private var isShowingSaveSuccessful: Bool = false
    @State private var isDeleted: Bool = false

    @State private var isAddingNewItem = false

    var body: some View {
        UnifiedPackingListView(
            lists: [packingList],
            users: packingList.user != nil ? [packingList.user!] : nil,
            listType: packingList.type,
            isDayOf: packingList.isDayOf,
            title: packingList.name,
            mode: .templating,
            isAddingNewItem: $isAddingNewItem
        )
        .navigationTitle(packingList.name)
        .navigationBarTitleDisplayMode(.inline)
        .overlay {
            VStack {
                Spacer()

                HStack {
                    Spacer()

                    Group {
                        if isAddingNewItem {
                            Button(action: cancelAddingNewItem) {
                                Image(systemName: "x.circle.fill")
                                    .resizable()
                                    .foregroundColor(.gray)
                            }
                            .frame(width: 60, height: 60)
                            .glassEffectIfAvailable()
                        } else {
                            Button(action: startAddingNewItem) {
                                Image(systemName: "plus.circle.fill")
                                    .resizable()
                                    .foregroundColor(.blue)
                            }
                            .frame(width: 60, height: 60)
                            .glassEffectIfAvailable()
                        }
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 20)
            }
        }
        .toolbar {
            ToolbarItemGroup {
                if !self.packingList.template {
                    Menu {
                        Button("Save As Default") {
                            withAnimation {
                                saveListAsDefault()
                            }
                        }
                    }  label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }

                Button {
                    isShowingListSettings.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
        }
        .alert("List saved as default", isPresented: $isShowingSaveSuccessful) {
            Button("OK", role: .cancel) {}
        }
        .sheet(isPresented: $isShowingListSettings) {
            PackingListEditView(packingList: packingList, isTemplate: packingList.template, isDeleted: $isDeleted)
        }
        .onChange(of: isDeleted) {
            dismiss()
        }
    }
    
    func saveListAsDefault() {
        let newDefaultList = PackingList.copyAsTemplate(self.packingList)
        modelContext.insert(newDefaultList)

        isShowingSaveSuccessful = true
    }

    private func startAddingNewItem() {
        withAnimation {
            isAddingNewItem = true
        }
    }

    private func cancelAddingNewItem() {
        withAnimation {
            isAddingNewItem = false
        }
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var lists: [PackingList]
    NavigationStack {
        PackingListDetailView(packingList: lists.first!)
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query(filter: #Predicate<PackingList> { list in
        list.template == true
    }) var lists: [PackingList]
    NavigationStack {
        PackingListDetailView(packingList: lists.first!)
    }
}
