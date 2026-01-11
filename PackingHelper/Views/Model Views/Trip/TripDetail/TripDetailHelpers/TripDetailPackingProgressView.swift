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
    
    var upperVal: Double {
        if total > 0 {
            return total
        }
        return Double(Int.max)
    }
    
    var body: some View {
        HStack {
            Gauge(value: val, in: 0...upperVal) {
                Image(systemName: image)
                    .imageScale(.small)
            }
            .gaugeStyle(.accessoryCircularCapacity)
            .tint(val == total && total > 0 ? .green : .accent)
            .animation(.smooth, value: val)
        }
    }
}

#Preview {
    TripDetailPackingProgressView(val: 3, total: 12, image: "tshirt")
}
