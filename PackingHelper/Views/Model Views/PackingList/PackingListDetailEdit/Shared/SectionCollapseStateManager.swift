//
//  SectionCollapseStateManager.swift
//  PackingHelper
//
//  Created by Claude on 1/11/26.
//

import Foundation
import SwiftData

class SectionCollapseStateManager {
    private static let userDefaultsKey = "sectionCollapseStates"

    static func loadCollapsedSections(for tripId: PersistentIdentifier) -> Set<String> {
        let tripKey = String(tripId.hashValue)
        let defaults = UserDefaults.standard

        if let statesDict = defaults.dictionary(forKey: userDefaultsKey) as? [String: [String]],
           let collapsedIds = statesDict[tripKey] {
            return Set(collapsedIds)
        }

        return Set<String>()
    }

    static func saveCollapsedSections(_ sections: Set<String>, for tripId: PersistentIdentifier) {
        let tripKey = String(tripId.hashValue)
        let defaults = UserDefaults.standard

        var statesDict = defaults.dictionary(forKey: userDefaultsKey) as? [String: [String]] ?? [:]
        statesDict[tripKey] = Array(sections)

        defaults.set(statesDict, forKey: userDefaultsKey)
    }
}
