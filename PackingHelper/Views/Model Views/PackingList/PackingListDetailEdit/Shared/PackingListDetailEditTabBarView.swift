//
//  PackingListDetailEditTabBarView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/20/24.
//

import SwiftUI
import SwiftData

struct PackingListDetailEditTabBarView: View {
    @Namespace private var animation
    
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
            withAnimation(.bouncy) {
                currentView = resultView
            }
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(currentView == resultView ? Color.black : Color.accentColor)
    }
    
    var body: some View {
        HStack {
            ZStack {
                if currentView == .unpacked {
                    Color.accentColor.matchedGeometryEffect(id: "background", in: animation)
                }
                tabButton(title: buttonLeftTitle, resultView: .unpacked)
            }
            
            ZStack {
                if currentView == .packed {
                    Color.accentColor.matchedGeometryEffect(id: "background", in: animation)
                }
                tabButton(title: buttonRightTitle, resultView: .packed)
            }
        }
        .frame(height: 40)
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
