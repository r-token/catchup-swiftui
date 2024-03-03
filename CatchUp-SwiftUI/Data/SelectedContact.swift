//
//  SelectedContact.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/3/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//
//

import Foundation
import SwiftData

@Model
class SelectedContact {
    var address: String
    var anniversary: String
    var anniversary_notification_id: UUID
    var birthday: String
    var birthday_notification_id: UUID
    var email: String
    var id: UUID
    var name: String
    var notification_identifier: UUID
    var notification_preference: Int16 = 0
    var notification_preference_custom_day: Int16 = 0
    var notification_preference_custom_month: Int16 = 0
    var notification_preference_custom_year: Int16 = 0
    var notification_preference_hour: Int16 = 0
    var notification_preference_minute: Int16 = 0
    var notification_preference_weekday: Int16 = 0
    var phone: String
    var picture: String
    var secondary_address: String
    var secondary_email: String
    var secondary_phone: String

    init(
        address: String,
        anniversary: String,
        anniversary_notification_id: UUID,
        birthday: String,
        birthday_notification_id: UUID,
        email: String,
        id: UUID,
        name: String,
        notification_identifier: UUID,
        notification_preference: Int16,
        notification_preference_custom_day: Int16,
        notification_preference_custom_month: Int16,
        notification_preference_custom_year: Int16,
        notification_preference_hour: Int16,
        notification_preference_minute: Int16,
        notification_preference_weekday: Int16,
        phone: String,
        picture: String,
        secondary_address: String,
        secondary_email: String,
        secondary_phone: String
    ) {
        self.address = address
        self.anniversary = anniversary
        self.anniversary_notification_id = anniversary_notification_id
        self.birthday = birthday
        self.birthday_notification_id = birthday_notification_id
        self.email = email
        self.id = id
        self.name = name
        self.notification_identifier = notification_identifier
        self.notification_preference = notification_preference
        self.notification_preference_custom_day = notification_preference_custom_day
        self.notification_preference_custom_month = notification_preference_custom_month
        self.notification_preference_custom_year = notification_preference_custom_year
        self.notification_preference_hour = notification_preference_hour
        self.notification_preference_minute = notification_preference_minute
        self.notification_preference_weekday = notification_preference_weekday
        self.phone = phone
        self.picture = picture
        self.secondary_address = secondary_address
        self.secondary_email = secondary_email
        self.secondary_phone = secondary_phone
    }

}
