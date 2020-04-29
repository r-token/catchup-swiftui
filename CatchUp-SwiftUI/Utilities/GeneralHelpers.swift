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

struct GeneralHelpers {
    
    func clearNotificationBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    func saveMOC(moc: NSManagedObjectContext) {
        do {
            try moc.save()
        } catch let error as NSError {
            print("Could not update the MOC. \(error), \(error.userInfo)")
        }
    }
    
}
