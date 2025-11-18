//
//  UNUserNotificationCenter+Async.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/18/2025.
//  Copyright © 2025 Token Solutions. All rights reserved.
//

import UserNotifications

extension UNUserNotificationCenter {
    /// Removes pending notification requests and waits for completion
    /// - Parameters:
    ///   - identifiers: The notification identifiers to remove
    func remove(_ identifiers: [String]) async {
        guard !identifiers.isEmpty else { return }
        
        self.removePendingNotificationRequests(withIdentifiers: identifiers)
        
        // Wait a moment for removal to complete
        try? await Task.sleep(nanoseconds: 100_000_000) // 100ms
    }
}
