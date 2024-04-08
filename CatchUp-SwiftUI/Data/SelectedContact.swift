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
    var address: String = ""
    var anniversary: String = ""
    var anniversary_notification_id: UUID = UUID()
    var birthday: String = ""
    var birthday_notification_id: UUID = UUID()
    var email: String = ""
    var id: UUID = UUID()
    var name: String = ""
    var notification_identifier: UUID = UUID()
    var notification_preference: Int = 0
    var notification_preference_custom_day: Int = 0
    var notification_preference_custom_month: Int = 0
    var notification_preference_custom_year: Int = 0
    var notification_preference_hour: Int = 0
    var notification_preference_minute: Int = 0
    var notification_preference_weekday: Int = 0
    var notification_preference_week_of_month: Int = 0
    var phone: String = ""
    var picture: String = ""
    var secondary_address: String = ""
    var secondary_email: String = ""
    var secondary_phone: String = ""
    var next_notification_date_time: String = ""
    var unread_badge_date_time: String = ""

    init(
        address: String,
        anniversary: String,
        anniversary_notification_id: UUID,
        birthday: String,
        birthday_notification_id: UUID,
        email: String,
        id: UUID,
        name: String,
        next_notification_date_time: String,
        notification_identifier: UUID,
        notification_preference: Int,
        notification_preference_custom_day: Int,
        notification_preference_custom_month: Int,
        notification_preference_custom_year: Int,
        notification_preference_hour: Int,
        notification_preference_minute: Int,
        notification_preference_weekday: Int,
        notification_preference_week_of_month: Int,
        phone: String,
        picture: String,
        secondary_address: String,
        secondary_email: String,
        secondary_phone: String,
        unread_badge_date_time: String
    ) {
        self.address = address
        self.anniversary = anniversary
        self.anniversary_notification_id = anniversary_notification_id
        self.birthday = birthday
        self.birthday_notification_id = birthday_notification_id
        self.email = email
        self.id = id
        self.name = name
        self.next_notification_date_time = next_notification_date_time
        self.notification_identifier = notification_identifier
        self.notification_preference = notification_preference
        self.notification_preference_custom_day = notification_preference_custom_day
        self.notification_preference_custom_month = notification_preference_custom_month
        self.notification_preference_custom_year = notification_preference_custom_year
        self.notification_preference_hour = notification_preference_hour
        self.notification_preference_minute = notification_preference_minute
        self.notification_preference_weekday = notification_preference_weekday
        self.notification_preference_week_of_month = notification_preference_week_of_month
        self.phone = phone
        self.picture = picture
        self.secondary_address = secondary_address
        self.secondary_email = secondary_email
        self.secondary_phone = secondary_phone
        self.unread_badge_date_time = unread_badge_date_time
    }

    func preferenceIsNever() -> Bool {
        notification_preference == 0
    }

    func preferenceIsDaily() -> Bool {
        notification_preference == 1
    }

    func preferenceIsWeekly() -> Bool {
        notification_preference == 2
    }

    func preferenceIsMonthly() -> Bool {
        notification_preference == 3
    }

    func preferenceIsAnnually() -> Bool {
        notification_preference == 4
    }

    func preferenceIsCustom() -> Bool {
        notification_preference == 5
    }

    static let sampleData = SelectedContact(
        address: "2190 E 11th Ave",
        anniversary: "06/20/2020",
        anniversary_notification_id: UUID(),
        birthday: "05/16/1994",
        birthday_notification_id: UUID(),
        email: "ryantoken13@gmail.com",
        id: UUID(),
        name: "Ryan Token",
        next_notification_date_time: "",
        notification_identifier: UUID(),
        notification_preference: 0,
        notification_preference_custom_day: 3,
        notification_preference_custom_month: 0,
        notification_preference_custom_year: 0,
        notification_preference_hour: 12,
        notification_preference_minute: 0,
        notification_preference_weekday: 3,
        notification_preference_week_of_month: 2,
        phone: "6363687771",
        picture: "photo-as-data-string",
        secondary_address: "",
        secondary_email: "",
        secondary_phone: "",
        unread_badge_date_time: ""
    )
}
