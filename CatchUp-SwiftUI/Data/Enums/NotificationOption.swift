//
//  NotificationOption.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/7/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

enum NotificationOption: String, CaseIterable {
    case never = "Never"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"
    case quarterly = "Quarterly"
    case annually = "Annually"
    case custom = "Custom"
}
