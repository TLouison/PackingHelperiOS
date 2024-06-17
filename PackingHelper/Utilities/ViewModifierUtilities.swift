//
//  ViewModifierUtilities.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/18/23.
//

import SwiftUI

struct Box: ViewModifier {
    let background: Material
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(background)
    }
}

struct Rounded: ViewModifier {
    func body(content: Content) -> some View {
        content
            .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
            .contentShape(.rect)
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
    func rounded()
        -> some View {
            modifier(Rounded())
      }
    
    func box(background: Material = .thinMaterial) -> some View {
        modifier(Box(background: background))
    }
    
    func roundedBox(background: Material = .thinMaterial) -> some View {
        modifier(Box(background: background)).modifier(Rounded())
    }
    
    func shaded() -> some View {
        modifier(Shaded())
    }
}
