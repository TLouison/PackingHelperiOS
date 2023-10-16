//
//  TransitionUtilities.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/14/23.
//

import SwiftUI

extension AnyTransition {
    static func pushAndPull(_ edge: Edge) -> AnyTransition {
        .asymmetric(
            insertion: .push(from: edge).combined(with: .opacity),
            removal: .move(edge: edge).combined(with: .opacity)
        )
    }
}
