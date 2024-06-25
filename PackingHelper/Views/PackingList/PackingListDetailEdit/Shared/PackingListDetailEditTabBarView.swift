//
//  PackingListDetailEditTabBarView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/20/24.
//

import SwiftUI
import SwiftData

struct PackingListDetailEditTabBarView: View {
    let listType: ListType
    
    @Binding var currentView: PackingListDetailViewCurrentSelection
    
    var buttonLeftTitle: String {
        if listType == .task {
            "Tasks"
        } else {
            "Unpacked"
        }
    }
    
    var buttonRightTitle: String {
        if listType == .task {
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
    PackingListDetailEditTabBarView(listType: .packing, currentView: $packingView)
    PackingListDetailEditTabBarView(listType: .task, currentView: $packingView)
}
