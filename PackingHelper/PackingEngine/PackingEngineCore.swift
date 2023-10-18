//
//  PackingEngineCore.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import Foundation

enum PackingRecommendationStatus {
    case result, empty
}

enum PackingRecommendationCategory: String {
    case clothing, technology, toiletries, other
}

struct PackingRecommendationResult {
    var status: PackingRecommendationStatus
    var category: PackingRecommendationCategory
    var item: String
    var count: Int
    var context: String
}

class PackingEngine {
    static var possibleItems = ["Underwear", "Shirt", "Pants", "Socks", "Phone Charger", "Deodorant", "Toothbrush", "Toothpaste"]
    
    static func suggest() -> PackingRecommendationResult {
        return PackingRecommendationResult(status: .result, category: .clothing, item: possibleItems.randomElement() ?? "Socks", count: Int.random(in: 1..<10), context: "Good idea!")
    }
}
