//
//  CollapsableSection.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI

struct CollapsibleSection<Content: View>: View {
    let title: String
    @State private var isExpanded: Bool = true
    
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Section(isExpanded: $isExpanded) {
            content()
        } header: {
            HStack {
                Text(title)
                
                Spacer()
                
                Button {
                    withAnimation(.smooth) {
                        isExpanded.toggle()
                    }
                } label: {
                    if isExpanded {
                        Image(systemName: "chevron.down")
                    } else {
                        Image(systemName: "chevron.right")
                    }
                }
                .contentTransition(.interpolate)
            }
        }
    }
}
