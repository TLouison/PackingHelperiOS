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
        Menu {
            // Create list options
            Button("Create New List") {
                withAnimation {
                    isAddingNewPackingList.toggle()
                }
            }

            if !defaultLists.isEmpty {
                Button("Apply Template List") {
                    withAnimation {
                        isApplyingDefaultPackingList.toggle()
                    }
                }
            }
        } label: {
            Label("Add List", systemImage: "plus.circle")
        }
    }
}

//#Preview {
//    CreateListMenu()
//}
