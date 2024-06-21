//
//  PackingListDetailEditTabBarView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/20/24.
//

import SwiftUI
import SwiftData

struct PackingListDetailEditTabBarView: View {
    let packingList: PackingList
    
    @Binding var currentView: PackingListDetailViewCurrentSelection
    
    var buttonLeftTitle: String {
        if packingList.type == .task {
            "Tasks"
        } else {
            "Unpacked"
        }
    }
    
    var buttonRightTitle: String {
        if packingList.type == .task {
            "Completed"
        } else {
            "Packed"
        }
    }
    
    @ViewBuilder func tabButton(title: String, resultView: PackingListDetailViewCurrentSelection) -> some View {
        Button(title) {
            withAnimation(.snappy) {
                currentView = resultView
            }
        }
        .padding(.vertical, 10)
        .padding(.horizontal, 5)
        .frame(maxWidth: .infinity)
        .background(currentView == resultView ? Color.accentColor : Color.clear)
        .foregroundStyle(currentView == resultView ? Color.black : Color.accentColor)
    }
    
    var body: some View {
        HStack {
            tabButton(title: buttonLeftTitle, resultView: .unpacked)
            tabButton(title: buttonRightTitle, resultView: .packed)
        }
        .background(.thinMaterial)
        .clipShape(Capsule())
        .fixedSize(horizontal: false, vertical: true)
        .padding(.horizontal)
    }
}

@available(iOS 18, *)
#Preview(traits: .sampleData) {
    @Previewable @Query var lists: [PackingList]
    @Previewable @State var packingView: PackingListDetailViewCurrentSelection = .unpacked
    PackingListDetailEditTabBarView(packingList: lists[lists.firstIndex {$0.type == .packing}!], currentView: $packingView)
    PackingListDetailEditTabBarView(packingList: lists[lists.firstIndex {$0.type == .task}!], currentView: $packingView)
}
