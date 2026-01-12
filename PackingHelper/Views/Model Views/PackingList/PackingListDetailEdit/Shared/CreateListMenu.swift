//
//  CreateListMenu.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/30/24.
//

import SwiftUI
import SwiftData

struct CreateListMenu: View {
    @Binding var isAddingNewPackingList: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    
    @Query(
        filter: #Predicate<PackingList>{ $0.template == true}
    ) private var defaultLists: [PackingList]
    
    var body: some View {
        if defaultLists.isEmpty {
            Button {
                withAnimation {
                    isAddingNewPackingList.toggle()
                }
            } label: {
                Label("Create List", systemImage: "plus.circle")
            }
        } else {
            Menu {
                Button("Create List") {
                    withAnimation {
                        isAddingNewPackingList.toggle()
                    }
                }
                Button("Apply Template List") {
                    withAnimation {
                        isApplyingDefaultPackingList.toggle()
                    }
                }
            } label: {
                Label("Create List", systemImage: "plus.circle")
            }
        }
    }
}

//#Preview {
//    CreateListMenu()
//}
