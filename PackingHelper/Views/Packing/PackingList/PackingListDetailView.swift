//
//  TripPackingView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI


struct PackingListDetailView: View {
    @Environment(\.dismiss) var dismiss
    
    var packingList: PackingList

    @State private var isShowingListSettings: Bool = false
    @State private var isDeleted: Bool = false
    
    var body: some View {
        VStack {
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
            
            Spacer()
            
            PackingAddItemView(packingList: packingList)
        }
        .navigationTitle(packingList.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    isShowingListSettings.toggle()
                } label: {
                    Label("List Settings", systemImage: "gear")
                        .labelStyle(.iconOnly)
                        .frame(width: 20, height: 20)
                }
            }
        }
        .sheet(isPresented: $isShowingListSettings) {
            PackingListEditView(packingList: packingList, isTemplate: packingList.template, isDeleted: $isDeleted)
                .presentationDetents([.height(225)])
        }
        .onChange(of: isDeleted) {
            dismiss()
        }
    }
}
