//
//  UserDefaults+isFirstLaunch.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation

extension UserDefaults {
    // check for is first launch on version 2.0 - only true on first invocation after app install, false on all further invocations
    // Note: this is used in AppDelegate.swift in didFinishLaunchingWithOptions
	static func isFirstVersion2Launch() -> Bool {
        let hasLaunchedVersion2BeforeFlag = "hasLaunchedVersion2BeforeFlag"
        let isFirstVersion2Launch = !UserDefaults.standard.bool(forKey: hasLaunchedVersion2BeforeFlag)
        if (isFirstVersion2Launch) {
            UserDefaults.standard.set(true, forKey: hasLaunchedVersion2BeforeFlag)
            UserDefaults.standard.synchronize()
        }
		isFirstVersion2Launch ? print("It is the first launch on version 2.0") : print("It is not the first launch on version 2.0")
        return isFirstVersion2Launch
    }
}
