//
//  GeneralHelpers.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/28/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import Foundation
import CoreData
import UserNotifications

struct GeneralHelpers {
    func clearNotificationBadge() {
        UNUserNotificationCenter.current().setBadgeCount(0)
    }
    
    func getCurrentAppVersion() -> String {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"]
        let version = (appVersion as! String)

        print(version)
        return version
    }
    
}
