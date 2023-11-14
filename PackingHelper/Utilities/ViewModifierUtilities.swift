//
//  ViewModifierUtilities.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/18/23.
//

import SwiftUI

struct RoundedBox: ViewModifier {
    let background: Material
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
            .contentShape(.rect)
            .shaded()
    }
}

struct Shaded: ViewModifier {
    func body(content: Content) -> some View {
        content
            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
            .shadow(color: .black.opacity(0.05), radius: 1, x: 0, y: 0.25)
    }
}

extension View {
    func roundedBox(background: Material = .thinMaterial)
        -> some View {
            modifier(RoundedBox(background: background))
      }
    
    func shaded() -> some View {
        modifier(Shaded())
    }
}
