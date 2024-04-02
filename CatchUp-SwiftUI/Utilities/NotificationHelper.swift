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
    @MainActor
    static func createNewNotification(for contact: SelectedContact) {
        updateNextNotificationDateTimeFor(contact: contact)
        
        let addRequest = {
            if preferenceIsNotSetToNever(for: contact) {
                addGeneralNotification(for: contact)
            }
            
            if ContactHelper.contactHasBirthday(contact) {
                addBirthdayNotification(for: contact)
            }
            
            if ContactHelper.contactHasAnniversary(contact) {
                addAnniversaryNotification(for: contact)
            }
        }

        checkNotificationAuthorizationStatusAndAddRequest(action: addRequest)
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

        scheduleNotification(for: contact, dateComponents: dateComponents, identifier: identifier, content: notificationContent)
    }
    
    static func addBirthdayNotification(for contact: SelectedContact) {
        let birthdayNotificationContent = UNMutableNotificationContent()
        birthdayNotificationContent.title = "🥳 Today is \(contact.name)'s birthday!"
        birthdayNotificationContent.body = "Be sure to CatchUp and wish them a great one!"
        birthdayNotificationContent.sound = UNNotificationSound.default
        birthdayNotificationContent.badge = 1

        let birthdayIdentifier = UUID()
        let birthdayDateComponents = getBirthdayDateComponents(for: contact)

        scheduleNotification(for: contact, dateComponents: birthdayDateComponents, identifier: birthdayIdentifier, content: birthdayNotificationContent)
    }
    
    static func addAnniversaryNotification(for contact: SelectedContact) {
        let anniversaryNotificationContent = UNMutableNotificationContent()
        anniversaryNotificationContent.title = "😍 Tomorrow is \(contact.name)'s anniversary!"
        anniversaryNotificationContent.body = "Be sure to CatchUp and wish them the best."
        anniversaryNotificationContent.sound = UNNotificationSound.default
        anniversaryNotificationContent.badge = 1

        let anniversaryIdentifier = UUID()
        let anniversaryDateComponents = getAnniversaryDateComponents(for: contact)

        scheduleNotification(for: contact, dateComponents: anniversaryDateComponents, identifier: anniversaryIdentifier, content: anniversaryNotificationContent)
    }
    
    static func checkNotificationAuthorizationStatusAndAddRequest(action: @escaping() -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                action()
            } else {
                UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        print("Scheduled new notification(s)")
                        action()
                    } else {
                        print("User isn't allowing notifications :(")
                    }
                }
            }
        }
    }
    
    static func getNotificationDateComponents(for contact: SelectedContact) -> DateComponents {
        var dateComponents = DateComponents()

        switch contact.notification_preference {
        case 0: // Never
            break
        case 1: // Daily
            dateComponents.hour = Int(contact.notification_preference_hour)
            dateComponents.minute = Int(contact.notification_preference_minute)
            break
        case 2: // Weekly
            dateComponents.hour = Int(contact.notification_preference_hour)
            dateComponents.minute = Int(contact.notification_preference_minute)
            // weekday units are 1-7, I store them as 0-6 though. Need to add 1
            dateComponents.weekday = Int(contact.notification_preference_weekday)+1
            break
        case 3: // Monthly
            dateComponents.hour = Int(contact.notification_preference_hour)
            dateComponents.minute = Int(contact.notification_preference_minute)
            dateComponents.weekday = Int(contact.notification_preference_weekday)+1
            dateComponents.weekOfMonth = Int(contact.notification_preference_week_of_month)
            break
        case 4: // Custom Date
            dateComponents.month = Int(contact.notification_preference_custom_month)
            dateComponents.day = Int(contact.notification_preference_custom_day)
            dateComponents.year = Int(contact.notification_preference_custom_year)
            dateComponents.hour = 12
            dateComponents.minute = 30
            break
        default:
            print("It's impossible to get here")
        }

        return dateComponents
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
    
    static func scheduleNotification(for contact: SelectedContact, dateComponents: DateComponents, identifier: UUID, content: UNMutableNotificationContent) {

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
        
        if content.title == "👋 CatchUp with \(contact.name)" {
            contact.notification_identifier = identifier
        } else if content.title == "🥳 Today is \(contact.name)'s birthday!" {
            contact.birthday_notification_id = identifier
        } else {
            contact.anniversary_notification_id = identifier
        }

        print("scheduling notification for contact: \(contact.name)")

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
        let newPreference = selection
        contact.notification_preference = newPreference
    }
    
    static func updateNotificationTime(for contact: SelectedContact, hour: Int, minute: Int) {
        let newHour = hour
        let newMinute = minute
        contact.notification_preference_hour = newHour
        contact.notification_preference_minute = newMinute
    }
    
    static func updateNotificationPreferenceWeekday(for contact: SelectedContact, weekday: Int) {
        let newWeekday = weekday
        contact.notification_preference_weekday = newWeekday
    }
    
    static func updateNotificationCustomDate(for contact: SelectedContact, month: Int, day: Int, year: Int) {
        let customMonth = month
        let customDay = day
        let customYear = year
        contact.notification_preference_custom_month = customMonth
        contact.notification_preference_custom_day = customDay
        contact.notification_preference_custom_year = customYear
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
        
        if ContactHelper.contactHasBirthday(contact) {
            removeBirthdayNotification(for: contact)
        }
        
        if ContactHelper.contactHasAnniversary(contact) {
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

    @MainActor
    static func updateNextNotificationDateTimeFor(contact: SelectedContact) {
        let nextNotificationDateTime = getNextNotificationDateFor(contact: contact)
        contact.next_notification_date_time = nextNotificationDateTime
    }

    static func getNextNotificationDateFor(contact: SelectedContact) -> String {
        // Get next notification date for the general notification
        var components = DateComponents()
        switch contact.notification_preference {
        case 1: // daily
            components.hour = contact.notification_preference_hour
            components.minute = contact.notification_preference_minute
        case 2, 3: // weekly, monthly
            components.hour = contact.notification_preference_hour
            components.minute = contact.notification_preference_minute
            components.weekday = contact.notification_preference_weekday + 1
            if contact.notification_preference_week_of_month != 0 {
                components.weekOfMonth = contact.notification_preference_week_of_month
            }
        case 4: // custom date
            components.hour = contact.notification_preference_hour
            components.minute = contact.notification_preference_minute
            components.month = contact.notification_preference_custom_month
            components.day = contact.notification_preference_custom_day
            components.year = contact.notification_preference_custom_year
        default:
            print("do nothing")
        }

        var soonestUpcomingNotificationDateString = "Unknown"
        print("components for \(contact.name): \(components)")
        soonestUpcomingNotificationDateString = calculateDateFromComponents(components)

        if ContactHelper.contactHasBirthday(contact) {
            let birthdayDateString = calculateDateFromComponents(getBirthdayDateComponents(for: contact))
            if birthdayDateString < soonestUpcomingNotificationDateString {
                soonestUpcomingNotificationDateString = birthdayDateString
            }
        }

        if ContactHelper.contactHasAnniversary(contact) {
            let anniversaryDateString = calculateDateFromComponents(getAnniversaryDateComponents(for: contact))
            if anniversaryDateString < soonestUpcomingNotificationDateString {
                soonestUpcomingNotificationDateString = anniversaryDateString
            }
        }

        print("soonestUpcomingNotification for \(contact.name): \(soonestUpcomingNotificationDateString)")
        return soonestUpcomingNotificationDateString
    }

    static func calculateDateFromComponents(_ dateComponents: DateComponents) -> String {
        let calendar = Calendar.current
        let currentDate = Date()

        // Calculate the date based on the provided components and current date
        if let calculatedDate = calendar.nextDate(after: currentDate, matching: dateComponents, matchingPolicy: .nextTime) {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss" // Define the desired date format

            // Convert the calculated date to a human-readable date string
            let formattedDate = dateFormatter.string(from: calculatedDate)
            return formattedDate
        }

        print("returning Unknown for soonestUpcomingNotification")
        return "Unknown"
    }

    @MainActor
    static func resetNotifications(for selectedContacts: [SelectedContact], delayTime: Double) {
        DispatchQueue.main.asyncAfter(deadline: .now() + delayTime) {
            print("resetting notifications")
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

            for contact in selectedContacts {
                if contact.notification_preference != 0 {
                    NotificationHelper.createNewNotification(for: contact)
                }

                if contact.unread_badge_date_time == "" {
                    print("updating unread badge date time for \(contact.name)")
                    contact.unread_badge_date_time = contact.next_notification_date_time
                }
            }
        }
    }
}
