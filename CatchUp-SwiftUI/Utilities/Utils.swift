//
//  Utils.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/28/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import Foundation
import UserNotifications

struct Utils {
    static func clearAppIconNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }

    static func clearUnreadBadge(for contact: SelectedContact) {
        contact.unread_badge_date_time = contact.next_notification_date_time
    }

    nonisolated static func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        print(version)
        return version
    }

    nonisolated static func updateIsMajor() -> Bool {
        let version = getCurrentAppVersion()
        if version.suffix(2) == ".0" {
            return true
        } else {
            return false
        }
    }

    static func isPhone() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .phone
    }

    static func isiPadOrMac() -> Bool {
        return UIDevice.current.userInterfaceIdiom == .pad || UIDevice.current.userInterfaceIdiom == .mac
    }

    static func requestReviewManually() {
        guard let writeReviewURL = URL(string: "https://apps.apple.com/us/app/catchup-keep-in-touch/id1358023550?action=write-review") else {
            fatalError("Expected a valid URL")
        }
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
    }
}
