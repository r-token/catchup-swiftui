//
//  UNUserNotificationCenter+Async.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/18/2025.
//  Copyright © 2025 Token Solutions. All rights reserved.
//

import UserNotifications

extension UNUserNotificationCenter {
    /// Removes pending and delivered notification requests with the given identifiers.
    func remove(_ identifiers: [String]) async {
        guard !identifiers.isEmpty else { return }

        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        self.removeDeliveredNotifications(withIdentifiers: identifiers)

        // Brief yield so the system has a moment to process the removals before
        // any immediately-following scheduling call queries the queue again.
        try? await Task.sleep(for: .milliseconds(50))
    }
}
