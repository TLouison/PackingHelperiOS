//
//  TripDetailPackingProgressView.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/24/24.
//

import SwiftUI

struct TripDetailPackingProgressView: View {
    let val: Double
    let total: Double
    let image: String
    
    var body: some View {
        HStack {
            Gauge(value: val, in: 0...total) {
                Image(systemName: image)
                    .imageScale(.small)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(val == total ? .green : .accent)
        }
    }
}

#Preview {
    TripDetailPackingProgressView(val: 3, total: 12, image: "tshirt")
}
