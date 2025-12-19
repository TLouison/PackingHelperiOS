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
    @State private var newItemName = ""
    @State private var newItemCount = 1
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        UnifiedPackingListView(
            lists: [packingList],
            users: packingList.user != nil ? [packingList.user!] : nil,
            listType: packingList.type,
            title: packingList.name,
            mode: .templating,
            onAddList: nil
        )
        .navigationTitle(packingList.name)
        .navigationBarTitleDisplayMode(.inline)
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

    private func addNewItem() {
        guard !newItemName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            cancelAddingNewItem()
            return
        }
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            let newItem = Item(name: newItemName, category: "", count: newItemCount, isPacked: false)
            modelContext.insert(newItem)
            packingList.addItem(newItem)
            newItemName = ""
            newItemCount = 1
            isAddingNewItem = false
            isTextFieldFocused = false
        }
    }
    
    private func cancelAddingNewItem() {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            newItemName = ""
            newItemCount = 1
            isAddingNewItem = false
            isTextFieldFocused = false
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
