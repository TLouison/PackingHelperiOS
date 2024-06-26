//
//  CollapsableSection.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI

struct CollapsibleSection<Header: View, Content: View>: View {
    @State private var isExpanded: Bool = true
    
    @ViewBuilder var title: () -> Header
    @ViewBuilder var content: () -> Content
    
    var body: some View {
        Section(isExpanded: $isExpanded) {
            content()
        } header: {
            HStack {
                title()
                
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
