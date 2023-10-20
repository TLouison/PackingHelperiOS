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
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .contentShape(.rect)
    }
}

extension View {
    func roundedBox(background: Material = .thinMaterial)
        -> some View {
            modifier(RoundedBox(background: background))
      }
}
