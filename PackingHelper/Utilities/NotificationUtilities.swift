//
//  NotificationUtilities.swift
//  PackingHelper
//
//  Created by Todd Louison on 10/23/23.
//

import Foundation
import UserNotifications

struct NotificationUtilities {
    static func getNotificationPermission() {
        guard FeatureFlags.showingNotifications else { return }

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("All set!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
