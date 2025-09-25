//
//  NotificationHelper.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/21/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftData
import SwiftUI
import UserNotifications
import CoreData

struct NotificationHelper {
    static func createNewNotification(for contact: SelectedContact) async {
        updateNextNotificationDateTimeFor(contact: contact)

        // Check authorization first
        let isAuthorized = await checkNotificationAuthorizationStatusAndAddRequest()

        guard isAuthorized else {
            print("Notification authorization not granted")
            return
        }

        // Add the notifications if authorized
        if preferenceIsNotSetToNever(for: contact) {
            addGeneralNotification(for: contact)
        }

        if contact.hasBirthday() {
            addBirthdayNotification(for: contact)
        }

        if contact.hasAnniversary() {
            addAnniversaryNotification(for: contact)
        }
    }

    static func preferenceIsNotSetToNever(for contact: SelectedContact) -> Bool {
        return contact.notification_preference != 0 ? true : false
    }
    
    static func addGeneralNotification(for contact: SelectedContact) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "👋 CatchUp with \(contact.name)"
        notificationContent.body = generateRandomNotificationBody()
        notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = 1

        let identifier = UUID()
        let dateComponents = getNotificationDateComponents(for: contact)

        scheduleNotification(for: contact, isBirthdayOrAnniversary: false, dateComponents: dateComponents, identifier: identifier, content: notificationContent)
    }

    static func addBirthdayNotification(for contact: SelectedContact) {
        let birthdayNotificationContent = UNMutableNotificationContent()
        birthdayNotificationContent.title = "🥳 Today is \(contact.name)'s birthday!"
        birthdayNotificationContent.body = "Be sure to CatchUp and wish them a great one!"
        birthdayNotificationContent.sound = UNNotificationSound.default
        birthdayNotificationContent.badge = 1

        let birthdayIdentifier = UUID()
        let birthdayDateComponents = getBirthdayDateComponents(for: contact)

        scheduleNotification(for: contact, isBirthdayOrAnniversary: true, dateComponents: birthdayDateComponents, identifier: birthdayIdentifier, content: birthdayNotificationContent)
    }
    
    static func addAnniversaryNotification(for contact: SelectedContact) {
        let anniversaryNotificationContent = UNMutableNotificationContent()
        anniversaryNotificationContent.title = "😍 Tomorrow is \(contact.name)'s anniversary!"
        anniversaryNotificationContent.body = "Be sure to CatchUp and wish them the best."
        anniversaryNotificationContent.sound = UNNotificationSound.default
        anniversaryNotificationContent.badge = 1

        let anniversaryIdentifier = UUID()
        let anniversaryDateComponents = getAnniversaryDateComponents(for: contact)

        scheduleNotification(for: contact, isBirthdayOrAnniversary: true, dateComponents: anniversaryDateComponents, identifier: anniversaryIdentifier, content: anniversaryNotificationContent)
    }
    
    static func checkNotificationAuthorizationStatusAndAddRequest() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()

        if settings.authorizationStatus == .authorized {
            return true
        } else {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                if granted {
                    print("Notification authorization granted")
                } else {
                    print("User denied notification authorization")
                }
                return granted
            } catch {
                print("Error requesting notification authorization: \(error)")
                return false
            }
        }
    }

    static func getNextNotificationDateFor(contact: SelectedContact) -> String {
        // Get next notification date for the general notification
        var components = DateComponents()

        if contact.preferenceIsDaily() {
            components.hour = contact.notification_preference_hour
            components.minute = contact.notification_preference_minute
        } else if contact.preferenceIsWeekly() || contact.preferenceIsMonthly() {
            components.hour = contact.notification_preference_hour
            components.minute = contact.notification_preference_minute
            components.weekday = contact.notification_preference_weekday
            if contact.notification_preference_week_of_month != 0 {
                components.weekOfMonth = contact.notification_preference_week_of_month
            }
        } else if contact.preferenceIsQuarterly() {
            print("Quarterly is handled separately by UNTimeIntervalNotificationTrigger. Fallthrough.")
        } else if contact.preferenceIsAnnually() || contact.preferenceIsCustom() {
            components.minute = contact.notification_preference_minute
            components.hour = contact.notification_preference_hour
            components.day = contact.notification_preference_custom_day
            components.month = contact.notification_preference_custom_month
            if contact.preferenceIsAnnually() {
                components.year = nil
            } else if contact.preferenceIsCustom() {
                components.year = contact.notification_preference_custom_year
            }
        }

        var soonestUpcomingNotificationDateString = ""
        if contact.preferenceIsQuarterly() {
            soonestUpcomingNotificationDateString = getNextNotificationDateForQuarterlyPreference(contact: contact)
        } else {
            soonestUpcomingNotificationDateString = calculateDateStringFromComponents(components)
        }

        if contact.hasBirthday() && !contact.preferenceIsNever() {
            let birthdayDateString = calculateDateStringFromComponents(getBirthdayDateComponents(for: contact))
            if birthdayDateString < soonestUpcomingNotificationDateString {
                soonestUpcomingNotificationDateString = birthdayDateString
            }
        }

        if contact.hasAnniversary() && !contact.preferenceIsNever() {
            let anniversaryDateString = calculateDateStringFromComponents(getAnniversaryDateComponents(for: contact))
            if anniversaryDateString < soonestUpcomingNotificationDateString {
                soonestUpcomingNotificationDateString = anniversaryDateString
            }
        }

        return soonestUpcomingNotificationDateString
    }

    static func getNotificationDateComponents(for contact: SelectedContact) -> DateComponents {
        var dateComponents = DateComponents()

        if contact.preferenceIsDaily() {
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
        } else if contact.preferenceIsWeekly() {
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
            dateComponents.weekday = contact.notification_preference_weekday
        } else if contact.preferenceIsMonthly() {
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
            dateComponents.weekday = contact.notification_preference_weekday
            dateComponents.weekOfMonth = contact.notification_preference_week_of_month
        } else if contact.preferenceIsAnnually() || contact.preferenceIsCustom() {
            if contact.preferenceIsAnnually() {
                dateComponents.year = nil
            } else if contact.preferenceIsCustom() {
                dateComponents.year = contact.notification_preference_custom_year
            }
            dateComponents.month = contact.notification_preference_custom_month
            dateComponents.day = contact.notification_preference_custom_day
            dateComponents.hour = contact.notification_preference_hour
            dateComponents.minute = contact.notification_preference_minute
        }

        print("Notification date components for \(contact.name): \(dateComponents)")

        return dateComponents
    }

    static func getNextNotificationDateForQuarterlyPreference(contact: SelectedContact) -> String {
        if contact.notification_preference_quarterly_set_time.addingTimeInterval(Constants.ninetyDaysInSeconds) < Date() {
            print("resetting quarterly notification preference")
            // reset the quarterly set time and reset the notification
            contact.notification_preference_quarterly_set_time = Date()
            NotificationHelper.removeGeneralNotification(for: contact)
            NotificationHelper.addGeneralNotification(for: contact)
        }

        return calculateDateStringFromDate(contact.notification_preference_quarterly_set_time)
    }

    static func getBirthdayDateComponents(for contact: SelectedContact) -> DateComponents {
        var birthdayDateComponents = DateComponents()
        
        let month = (contact.birthday).prefix(2)
        let day = (contact.birthday).suffix(2)
        
        birthdayDateComponents.month = Int(month)
        birthdayDateComponents.day = Int(day)
        birthdayDateComponents.hour = 7
        birthdayDateComponents.minute = 15
        
        return birthdayDateComponents
    }
    
    static func getAnniversaryDateComponents(for contact: SelectedContact) -> DateComponents {
        var anniversaryDateComponents = DateComponents()
        let formatter = DateFormatter()
        
        formatter.dateFormat = "MM-dd"
        let anniversaryDate = formatter.date(from: contact.anniversary)!
        let previousDayDate = Calendar.current.date(byAdding: .day, value: -1, to: anniversaryDate)
        let previousDay = formatter.string(from: previousDayDate!)
        
        let month = (previousDay).prefix(2)
        let day = (previousDay).suffix(2)
        
        anniversaryDateComponents.month = Int(month)
        anniversaryDateComponents.day = Int(day)
        anniversaryDateComponents.hour = 7
        anniversaryDateComponents.minute = 30
        
        return anniversaryDateComponents
    }
    
    static func scheduleNotification(for contact: SelectedContact, isBirthdayOrAnniversary: Bool, dateComponents: DateComponents, identifier: UUID, content: UNMutableNotificationContent) {
        var calendarTrigger: UNCalendarNotificationTrigger?
        var timeIntervalTrigger: UNTimeIntervalNotificationTrigger?
        var request: UNNotificationRequest

        // quarterly notifications are handled by UNTimeIntervalNotificationTrigger instead of UNCalendarNotificationTrigger, so we handle them separately
        if contact.preferenceIsQuarterly() && !isBirthdayOrAnniversary {
            let oneDay: Double = 86400 // seconds
            // set a recurring time interval for every 90 days
            timeIntervalTrigger = UNTimeIntervalNotificationTrigger(timeInterval: (oneDay*90), repeats: true)
            request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: timeIntervalTrigger)
        } else {
            calendarTrigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: calendarTrigger)
        }

        if content.title == "👋 CatchUp with \(contact.name)" {
            contact.notification_identifier = identifier
        } else if content.title == "🥳 Today is \(contact.name)'s birthday!" {
            contact.birthday_notification_id = identifier
        } else {
            contact.anniversary_notification_id = identifier
        }

        if let timeIntervalTrigger {
            print("scheduling notification for \(contact.name) with time interval: \(timeIntervalTrigger.timeInterval)")
        } else {
            if let calendarTrigger {
                print("scheduling notification for \(contact.name) with date components: \(calendarTrigger.dateComponents)")
            }
        }

        UNUserNotificationCenter.current().add(request)
    }
    
    static func generateRandomNotificationBody() -> String {
        let randomInt = Int.random(in: 0..<20)
        
        switch randomInt {
            case 0:
                return "Now you can be best buddies again"
            case 1:
                return "A little birdy told me they really miss you"
            case 2:
                return "It's time to check back in"
            case 3:
                return "You're a good friend. Good for you. Tell this person to get CatchUp too so it's not always you who's reaching out"
            case 4:
                return "Today is the perfect day to get back in touch"
            case 5:
                return "Remember to keep in touch with the people that matter most"
            case 6:
                return "You know what they say: 'A CatchUp a day keeps the needy friends at bay'"
            case 7:
                return "Have you written a physical letter in a while? Maybe give that a try this time. People like that"
            case 8:
                return "Here's that reminder you set to check in with someone important. Maybe you'll make their day"
            case 9:
                return "Once a good person, always a good person (you are a good person, and probably so is the person you want to be reminded to CatchUp with)"
            case 10:
                return "Here's another reminder to get back in touch with ⬆️"
            case 11:
                return "Time to get back in contact with one of your favorite people"
            case 12:
                return "So nice of you to want to stay in touch with the people you care about"
            case 13:
                return "You know they'll really appreciate it"
            case 14:
                return "I'm not guilting you into this or anything, but this person will probably be sad if you don't say hello."
            case 15:
                return "You have this app, so you must be cool and nice. Now send a thoughtful message to this also cool and nice person"
            case 16:
                return "Once upon a time, there was a nice person. The end. (Spoiler: you're the nice person - keep being nice and reach out to your friend)"
            case 17:
                return "Another timely reminder to catch up. Just the way you wanted it"
            case 18:
                return "Now is the time! Seize the moment!"
            case 19:
                return "Good job keeping your friends close. Now keep your enemies closer 😉"
            default:
                return "Keep in touch"
        }
    }
    
    static func updateNotificationPreference(for contact: SelectedContact, selection: Int) {
        contact.notification_preference = selection
    }
    
    static func updateNotificationTime(for contact: SelectedContact, hour: Int, minute: Int) {
        contact.notification_preference_hour = hour
        contact.notification_preference_minute = minute
    }
    
    static func updateNotificationPreferenceWeekday(for contact: SelectedContact, weekday: Int) {
        contact.notification_preference_weekday = weekday
    }
    
    static func updateNotificationCustomDate(for contact: SelectedContact, month: Int, day: Int, year: Int) {
        contact.notification_preference_custom_month = month
        contact.notification_preference_custom_day = day
        contact.notification_preference_custom_year = year
    }
    
    static func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("User authorized CatchUp to send notifications")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    static func removeExistingNotifications(for contact: SelectedContact) {
        removeGeneralNotification(for: contact)
        
        if contact.hasBirthday() {
            removeBirthdayNotification(for: contact)
        }
        
        if contact.hasAnniversary() {
            removeAnniversaryNotification(for: contact)
        }
    }
    
    static func removeGeneralNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.notification_identifier.uuidString])

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending requests after removing existing request: \(requests.count)")
        }
    }
    
    static func removeBirthdayNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.birthday_notification_id.uuidString])
    }
    
    static func removeAnniversaryNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.anniversary_notification_id.uuidString])
    }

    static func updateNextNotificationDateTimeFor(contact: SelectedContact) {
        let nextNotificationDateTime = getNextNotificationDateFor(contact: contact)
        contact.next_notification_date_time = nextNotificationDateTime
    }

    static func getDateComponentsFromDate(_ date: Date) -> DateComponents {
        let calendar = Calendar.current
        let newDate = date.addingTimeInterval(Constants.ninetyDaysInSeconds)

        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: newDate)
        return dateComponents
    }

    static func calculateDateStringFromDate(_ date: Date) -> String {
        let dateComponents = getDateComponentsFromDate(date)
        return calculateDateStringFromComponents(dateComponents)
    }

    static func calculateDateStringFromComponents(_ dateComponents: DateComponents) -> String {
        let calendar = Calendar.current
        let currentDate = Date()

        // Calculate the date based on the provided components and current date
        if let calculatedDate = calendar.nextDate(after: currentDate, matching: dateComponents, matchingPolicy: .nextTime) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Define the desired date format

            // Convert the calculated date to a human-readable date string
            let formattedDate = dateFormatter.string(from: calculatedDate)
            // print("returning \(formattedDate)")
            return formattedDate
        }

        return "Unknown"
    }

    static func setYearPreference(for contact: SelectedContact) {
        var contactDateComponents = NotificationHelper.getNotificationDateComponents(for: contact)
        contactDateComponents.year = Calendar.current.component(.year, from: Date())
        if let nextNotificationDate = Calendar.current.date(from: contactDateComponents) {
            if nextNotificationDate < Date() {
                contact.notification_preference_custom_year = Calendar.current.component(.year, from: Date())+1
            } else {
                contact.notification_preference_custom_year = Calendar.current.component(.year, from: Date())
            }
            print("set \(contact.name)'s year preference to \(contact.notification_preference_custom_year)")
        }
    }

    static func resetNotifications(for selectedContacts: [SelectedContact], delayTime: Double) async {
        try? await Task.sleep(for: .seconds(delayTime))

        print("resetting notifications")
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        // Create notifications concurrently
        await withTaskGroup(of: Void.self) { group in
            for contact in selectedContacts {
                if contact.notification_preference != 0 {
                    group.addTask {
                        await NotificationHelper.createNewNotification(for: contact)
                    }
                }
            }
        }

        // Update unread badge times
        for contact in selectedContacts {
            if contact.unread_badge_date_time == "" {
                print("updating unread badge date time for \(contact.name)")
                contact.unread_badge_date_time = contact.next_notification_date_time
            }
        }
    }
}
