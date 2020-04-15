//
//  SelectedContact+CoreDataProperties.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/14/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//
//

import Foundation
import CoreData


extension SelectedContact {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelectedContact> {
        return NSFetchRequest<SelectedContact>(entityName: "SelectedContact")
    }

    @NSManaged public var address: String
    @NSManaged public var anniversary: String
    @NSManaged public var birthday: String
    @NSManaged public var email: String
    @NSManaged public var id: UUID
    @NSManaged public var name: String
    @NSManaged public var notification_identifier: UUID
    @NSManaged public var notification_preference: Int16
    @NSManaged public var phone: String
    @NSManaged public var picture: String
    @NSManaged public var secondary_address: String
    @NSManaged public var secondary_email: String
    @NSManaged public var secondary_phone: String
    @NSManaged public var notification_preference_hour: Int16
    @NSManaged public var notification_preference_minute: Int16
    @NSManaged public var notification_preference_customdate: Date
    @NSManaged public var birthday_notification_id: UUID
    @NSManaged public var anniversary_notification_id: UUID
    @NSManaged public var notification_preference_weekday: Int16

}
