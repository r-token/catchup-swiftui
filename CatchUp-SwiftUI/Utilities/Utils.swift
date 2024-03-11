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

class Utils {
    static func clearNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
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

    static func fetchAvailableIAPs() {
        print("fetching IAPs")
        IAPService.shared.fetchAvailableProducts()
    }
}
