//
//  NotificationID.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/18/2025.
//  Copyright © 2025 Token Solutions. All rights reserved.
//

import Foundation

/// Provides stable, deterministic notification identifiers based on contact IDs.
/// Using the same identifier when scheduling a notification causes iOS to replace
/// the existing notification, preventing duplicates.
///
/// Format:
/// - Thread: `contact.<uuid>`
/// - Per-kind:  `contact.<uuid>.general` | `.birthday` | `.anniversary`
enum NotificationID {
    static let prefix = "contact."

    static func thread(_ contact: SelectedContact) -> String {
        "\(prefix)\(contact.id.uuidString)"
    }

    static func general(_ contact: SelectedContact) -> String {
        "\(thread(contact)).general"
    }

    static func birthday(_ contact: SelectedContact) -> String {
        "\(thread(contact)).birthday"
    }

    static func anniversary(_ contact: SelectedContact) -> String {
        "\(thread(contact)).anniversary"
    }

    /// Extracts the contact UUID embedded in a stable notification identifier or thread.
    /// Returns `nil` for any string that doesn't follow the stable scheme — those are
    /// considered legacy and eligible for cleanup.
    static func extractContactUUID(from string: String) -> String? {
        guard string.hasPrefix(prefix) else { return nil }
        let components = string.split(separator: ".", maxSplits: 2, omittingEmptySubsequences: false)
        // Expect ["contact", "<uuid>", ...]
        guard components.count >= 2 else { return nil }
        let candidate = String(components[1])
        return UUID(uuidString: candidate) != nil ? candidate : nil
    }
}
