//
//  Utils.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/28/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import Foundation
import CoreData
import UserNotifications

struct Utils {
    static func clearAppIconNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    @MainActor
    static func clearUnreadBadge(for contact: SelectedContact) {
        contact.unread_badge_date_time = contact.next_notification_date_time
    }

    static func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        print(version)
        return version
    }
    
    static func updateIsMajor() -> Bool {
        let version = getCurrentAppVersion()
        if version.suffix(2) == ".0" {
            return true
        } else {
            return false
        }
    }

    @MainActor
    static func fetchAvailableIAPs() {
        print("fetching IAPs")
        IAPService.shared.fetchAvailableProducts()
    }

    @MainActor
    static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    @MainActor
    static func isiPadOrMac() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    @MainActor
    static func requestReviewManually() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/us/app/catchup-keep-in-touch/id1358023550?action=write-review") else {
            fatalError("Expected a valid URL")
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}
