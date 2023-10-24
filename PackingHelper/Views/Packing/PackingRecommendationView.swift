//
//  PackingRecommendationView.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import SwiftUI

struct PackingRecommendationView: View {
    let recommendation: PackingRecommendationResult
    
    var body: some View {
        VStack {
            Text("Recommended Item").bold()
            HStack {
                VStack(alignment: .leading) {
                    Text(recommendation.category.rawValue.capitalized).font(.caption)
                    Text(recommendation.item).font(.title)
                }
                Spacer()
                VStack {
                    Text("Count").font(.caption)
                    Text(String(recommendation.count)).font(.title).bold()
                }
            }
        }
        .padding()
        .background(.ultraThickMaterial)
        .clipShape(RoundedRectangle(cornerRadius: defaultCornerRadius))
    }
}

//#Preview {
//    PackingRecommendationView()
//}
