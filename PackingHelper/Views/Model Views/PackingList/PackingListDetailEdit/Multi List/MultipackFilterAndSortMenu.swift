//
//  MultipackFilterAndSortMenu.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/29/24.
//

import SwiftUI

struct MultipackFilterAndSortMenu: View {
    @Binding var user: User?
    @Binding var selectedList: PackingList?
    @Binding var sortOrder: PackingListSortOrder
    
    @Binding var isShowingEditList: Bool
    @Binding var isApplyingDefaultPackingList: Bool
    
    var body: some View {
        Menu {
            Button {
                selectedList = nil
                isShowingEditList.toggle()
            } label: {
                Label("Add New List", systemImage: "plus.circle")
            }
            Button {
                isApplyingDefaultPackingList.toggle()
            } label: {
                Label("Apply Default List", systemImage: "suitcase.rolling.fill")
            }
            
            Picker("Sort By", selection: $sortOrder) {
                ForEach(PackingListSortOrder.allCases, id: \.rawValue) { ordering in
                    if ordering != .byUser || user == nil {
                        Text(ordering.name).tag(ordering)
                    }
                }
            }
            
            UserPickerBaseView(selectedUser: $user.animation())
            
        } label: {
            Label("Filter and Sort", systemImage: "line.3.horizontal.decrease.circle.fill")
        }
        .menuStyle(.borderlessButton)
        .menuIndicator(.automatic)
        .menuOrder(.priority)
    }
}

//
