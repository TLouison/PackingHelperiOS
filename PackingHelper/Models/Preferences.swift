//
//  Preferences.swift
//  PackingHelper
//
//  Created by Todd Louison on 6/23/24.
//

import Foundation
import SwiftData

final class Preferences {
    var selectedUserPersistentID: PersistentIdentifier? = nil
    
    init() {
        selectedUserPersistentID = UserDefaults.standard.object(forKey: "selectedUserPersistentID") as? PersistentIdentifier
    }
    
    func setSelectedUser(_ user: User?) {
        if let user {
            selectedUserPersistentID = user.persistentModelID
        } else {
            selectedUserPersistentID = nil
        }
    }
    
    func getSelectedUser(in context: ModelContext) -> User? {
        if selectedUserPersistentID == nil {
            return nil
        }
        
        var fetchDescriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.persistentModelID == selectedUserPersistentID! },
            sortBy: [.init(\.created)]
        )
        fetchDescriptor.fetchLimit = 1
        
        do {
            return try context.fetch(fetchDescriptor).first
        } catch {
            return nil
        }
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
