//
//  PackingEngineCore.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/16/23.
//

import Foundation
import CoreML

enum PackingRecommendationStatus {
    case result, empty
}

enum PackingRecommendationCategory: String, CaseIterable {
    case Clothing, Electronics, Toiletries, Task, other
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
        return PackingRecommendationResult(status: .result, category: .Clothing, item: possibleItems.randomElement() ?? "Socks", count: Int.random(in: 1..<10), context: "Good idea!")
    }
    
//    static func suggestQuantity(itemName: String) -> Int {
//        return PackingRecommendationResult(status: .result, category:)
//    }
    
    static func interpretItem(itemName: String) -> PackingRecommendationCategory {
        let modelConfiguration = MLModelConfiguration()
        modelConfiguration.computeUnits = .all
        modelConfiguration.modelDisplayName = "Packed Item Classifier"
        let model = try! ProductSuggestionModel(configuration: modelConfiguration)
        
        guard let productCategoryOutput = try? model.prediction(text: itemName) else {
            fatalError("Unexpected runtime error.")
        }
        
        let categoryString = productCategoryOutput.label
        
        switch categoryString {
            case "Electronics": return PackingRecommendationCategory.Electronics
            case "Clothing": return PackingRecommendationCategory.Clothing
            case "Toiletry": return PackingRecommendationCategory.Toiletries
            default: return PackingRecommendationCategory.other
        }
    }
}
