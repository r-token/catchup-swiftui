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
enum NotificationID {
    /// Returns the thread identifier for a contact's notifications
    static func thread(_ contact: SelectedContact) -> String {
        "contact.\(contact.id.uuidString)"
    }
    
    /// Returns the identifier for a contact's general (recurring) notification
    static func general(_ contact: SelectedContact) -> String {
        "\(thread(contact)).general"
    }
    
    /// Returns the identifier for a contact's birthday notification
    static func birthday(_ contact: SelectedContact) -> String {
        "\(thread(contact)).birthday"
    }
    
    /// Returns the identifier for a contact's anniversary notification
    static func anniversary(_ contact: SelectedContact) -> String {
        "\(thread(contact)).anniversary"
    }
}
