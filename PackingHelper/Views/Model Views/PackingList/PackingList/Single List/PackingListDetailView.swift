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
    
    var body: some View {
        VStack {
            if packingList.template == false {
                PackingListDetailEditTabBarView(listType: packingList.type, currentView: $currentView)
                    .padding(.top)
            }
            
            if (packingList.items?.isEmpty ?? true) {
                ContentUnavailableView {
                    Label("No Items On List", systemImage: "bag")
                } description: {
                    Text("You haven't added any items to your list. Add one now to start your packing!")
                }
            } else {
                PackingListDetailEditView(packingList: packingList, currentView: $currentView)
            }
            
            if currentView == .unpacked {
                Spacer()
                
                PackingAddItemView(packingList: packingList)
                    .padding(.bottom)
                    .transition(.pushAndPull(.bottom))
            }
        }
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
