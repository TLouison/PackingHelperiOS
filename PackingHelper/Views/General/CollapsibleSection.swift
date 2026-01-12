//
//  CollapsableSection.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/25/24.
//

import SwiftUI

struct CollapsibleSection<Header: View, Content: View>: View {
    @State private var internalExpanded: Bool = true
    private var externalExpanded: Binding<Bool>?
    private var usesExternalBinding: Bool

    @ViewBuilder var title: () -> Header
    @ViewBuilder var content: () -> Content

    private var isExpanded: Binding<Bool> {
        externalExpanded ?? $internalExpanded
    }

    // Existing initializer (internal state) - for backward compatibility
    init(@ViewBuilder title: @escaping () -> Header, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
        self.usesExternalBinding = false
    }

    // New initializer (external binding) - for controlled expansion
    init(isExpanded: Binding<Bool>, @ViewBuilder title: @escaping () -> Header, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
        self.externalExpanded = isExpanded
        self.usesExternalBinding = true
    }

    var body: some View {
        Section(isExpanded: isExpanded) {
            content()
        } header: {
            HStack {
                title()

                Spacer()

                Button {
                    withAnimation(.snappy) {
                        isExpanded.wrappedValue.toggle()
                    }
                } label: {
                    Image(systemName: "chevron.down")
                        .rotationEffect(isExpanded.wrappedValue ? .degrees(0): .degrees(-90))
                        .contentTransition(.interpolate)
                }
            }
        }
    }
}
