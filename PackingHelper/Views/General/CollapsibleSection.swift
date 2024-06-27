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
                    withAnimation(.snappy) {
                        isExpanded.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(isExpanded ? .degrees(0): .degrees(-90))
                        .contentTransition(.interpolate)
                }
            }
        }
    }
}
