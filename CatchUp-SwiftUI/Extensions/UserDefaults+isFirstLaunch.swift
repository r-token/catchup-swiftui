//
//  UserDefaults+isFirstLaunch.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation

extension UserDefaults {
	
    // check for is first launch - only true on first invocation after app install, false on all further invocations
    // Note: this is used in AppDelegate.swift in didFinishLaunchingWithOptions
    static func isFirstLaunch() -> Bool {
        let hasBeenLaunchedBeforeFlag = "hasBeenLaunchedBeforeFlag"
        let isFirstLaunch = !UserDefaults.standard.bool(forKey: hasBeenLaunchedBeforeFlag)
        if (isFirstLaunch) {
            UserDefaults.standard.set(true, forKey: hasBeenLaunchedBeforeFlag)
            UserDefaults.standard.synchronize()
        }
		isFirstLaunch ? print("It is the first launch") : print("It is not the first launch")
        return isFirstLaunch
    }
}
