//
//  TripPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI


struct PackingListDetailView: View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.dismiss) var dismiss
    
    var packingList: PackingList

    @State private var isShowingListSettings: Bool = false
    @State private var isShowingSaveSuccessful: Bool = false
    @State private var isDeleted: Bool = false
    
    var body: some View {
        VStack {
            ZStack {
                if packingList.items.isEmpty {
                    ContentUnavailableView {
                        Label("No Items On List", systemImage: "bag")
                    } description: {
                        Text("You haven't added any items to your list. Add one now to track your packing!")
                    }
                } else {
                    if packingList.template == true || packingList.type == .dayOf {
                        UncategorizedPackingView(packingList: packingList)
                    } else if packingList.type == .task {
                        TaskPackingView(list: packingList)
                    } else {
                        CategorizedPackingView(packingList: packingList)
                    }
                }
            }
            
            Spacer()
            
            PackingAddItemView(packingList: packingList)
        }
        .navigationTitle(packingList.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup {
                Menu {
                    Button("Save As Default") {
                        withAnimation {
                            saveListAsDefault()
                        }
                    }
                }  label: {
                    Image(systemName: "square.and.arrow.up")
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
                .presentationDetents([.height(250)])
        }
        .onChange(of: isDeleted) {
            dismiss()
        }
    }
    
    func saveListAsDefault() {
        let newDefaultList = PackingList.copy(self.packingList)
        newDefaultList.template = true
        modelContext.insert(newDefaultList)
        
        isShowingSaveSuccessful = true
    }
}
