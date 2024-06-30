//
//  Preferences.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import SwiftData

@Model
final class Preferences {
    init() {
        
    }
}
//
//// Extension to handle getting the singleton preference model instance
//extension Preferences {
//    static func instance(with modelContext: ModelContext) -> Preferences {
//        do {
//            if let result = try modelContext.fetch(FetchDescriptor<Preferences>()).first {
//                return result
//            } else {
//                let instance = Preferences()
//                modelContext.insert(instance)
//                return instance
//            }
//        } catch {
//            let instance = Preferences()
//            modelContext.insert(instance)
//            return instance
//        }
//    }
//    
//    static func ensureExists(with modelContext: ModelContext) {
//        _ = instance(with: modelContext)
//    }
//}
