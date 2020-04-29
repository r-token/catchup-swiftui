//
//  NotificationService.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/21/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import UserNotifications
import CoreData

struct NotificationService {
    let notificationCenter = UNUserNotificationCenter.current()
    let helper = GeneralHelpers()
    let contactService = ContactService()
    
    func createNewNotification(for contact: SelectedContact, moc: NSManagedObjectContext) {
        let addRequest = {
            if self.contactService.preferenceIsNotSetToNever(for: contact) {
                self.addGeneralNotification(for: contact, moc: moc)
            }
            
            if self.contactService.contactHasBirthday(contact) {
                self.addBirthdayNotification(for: contact, moc: moc)
            }
            
            if self.contactService.contactHasAnniversary(contact) {
                self.addAnniversaryNotification(for: contact, moc: moc)
            }
        }

        checkNotificationAuthorizationStatusAndAddRequest(action: addRequest)
    }
    
    func checkNotificationAuthorizationStatusAndAddRequest(action: @escaping() -> Void) {
        notificationCenter.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                action()
                print("Scheduled new notification(s)")
            } else {
                self.notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        action()
                    } else {
                        print("User isn't allowing notifications :(")
                    }
                }
            }
        }
    }
    
    func setNotificationDateComponents(for contact: SelectedContact) -> DateComponents {
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
            dateComponents.weekOfMonth = Int.random(in: 2..<5)
            break
        case 4: // Custom Date
            dateComponents.month = Int(contact.notification_preference_custom_month)
            dateComponents.day = Int(contact.notification_preference_custom_day)
            dateComponents.year = Int(contact.notification_preference_custom_year)
            dateComponents.hour = 12
            dateComponents.minute = 30
            print(dateComponents)
            break
        default:
            print("It's impossible to get here")
        }
        
        return dateComponents
    }
    
    func setBirthdayDateComponents(for contact: SelectedContact) -> DateComponents {
        var birthdayDateComponents = DateComponents()
        
        let month = (contact.birthday).prefix(2)
        let day = (contact.birthday).suffix(2)
        
        birthdayDateComponents.month = Int(month)
        birthdayDateComponents.day = Int(day)
        birthdayDateComponents.hour = 7
        birthdayDateComponents.minute = 15
        
        return birthdayDateComponents
    }
    
    func setAnniversaryDateComponents(for contact: SelectedContact) -> DateComponents {
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
    
    func addGeneralNotification(for contact: SelectedContact, moc: NSManagedObjectContext) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "👋 CatchUp with \(contact.name)"
        notificationContent.body = self.generateRandomNotificationBody()
        notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = 1

        let identifier = UUID()
        let dateComponents = self.setNotificationDateComponents(for: contact)
        
        self.scheduleNotification(for: contact, dateComponents: dateComponents, identifier: identifier, content: notificationContent, moc: moc)
    }
    
    func addBirthdayNotification(for contact: SelectedContact, moc: NSManagedObjectContext) {
        let birthdayNotificationContent = UNMutableNotificationContent()
        birthdayNotificationContent.title = "🥳 Today is \(contact.name)'s birthday!"
        birthdayNotificationContent.body = "Be sure to CatchUp and wish them a great one!"
        birthdayNotificationContent.sound = UNNotificationSound.default
        birthdayNotificationContent.badge = 1

        let birthdayIdentifier = UUID()
        let birthdayDateComponents = self.setBirthdayDateComponents(for: contact)
        
        self.scheduleNotification(for: contact, dateComponents: birthdayDateComponents, identifier: birthdayIdentifier, content: birthdayNotificationContent, moc: moc)
    }
    
    func addAnniversaryNotification(for contact: SelectedContact, moc: NSManagedObjectContext) {
        let anniversaryNotificationContent = UNMutableNotificationContent()
        anniversaryNotificationContent.title = "😍 Tomorrow is \(contact.name)'s anniversary!"
        anniversaryNotificationContent.body = "Be sure to CatchUp and wish them the best."
        anniversaryNotificationContent.sound = UNNotificationSound.default
        anniversaryNotificationContent.badge = 1

        let anniversaryIdentifier = UUID()
        let anniversaryDateComponents = self.setAnniversaryDateComponents(for: contact)
        
        self.scheduleNotification(for: contact, dateComponents: anniversaryDateComponents, identifier: anniversaryIdentifier, content: anniversaryNotificationContent, moc: moc)
    }
    
    func scheduleNotification(for contact: SelectedContact, dateComponents: DateComponents, identifier: UUID, content: UNMutableNotificationContent, moc: NSManagedObjectContext) {
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
        
        moc.performAndWait {
            if content.title == "👋 CatchUp with \(contact.name)" {
                contact.notification_identifier = identifier
                print("updated general notification with ID \(identifier)")
            } else if content.title == "🥳 Today is \(contact.name)'s birthday!" {
                contact.birthday_notification_id = identifier
                print("updated birthday notification with ID \(identifier)")
            } else {
                contact.anniversary_notification_id = identifier
                print("updated anniversary notification with ID \(identifier)")
            }
        }
        self.helper.saveMOC(moc: moc)
        
        notificationCenter.add(request)
    }
    
    func generateRandomNotificationBody() -> String {
        let randomInt = Int.random(in: 0..<20)
        
        switch randomInt {
            case 0:
                return "Now you can be best buddies again"
            case 1:
                return "A little birdy told me they really miss you"
            case 2:
                return "It's time to check back in"
            case 3:
                return "You're a good friend. Go you. Tell this person to get CatchUp too so it's not always you who's reaching out"
            case 4:
                return "Today is the perfect day to get back in touch"
            case 5:
                return "Remember to keep in touch with the people that matter most"
            case 6:
                return "You know what they say: 'A CatchUp message a day keeps the needy friends at bay'"
            case 7:
                return "Have you written a physical letter in a while? Maybe give that a try this time? People like that"
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
                return "I'm not guilting you into this or anything, but this person will probably be subconsciously sad if you don't say hello."
            case 15:
                return "You have this app, so you're cool and nice. Now send a thoughtful message to this also cool and nice person"
            case 16:
                return "Once upon a time, there was a nice person. The end. (Spoiler: you're the nice person - keep being nice and reach out to this person)"
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
    
    func updateNotificationPreference(for contact: SelectedContact, selection: Int, moc: NSManagedObjectContext) {
        let newPreference = selection
        moc.performAndWait {
            contact.notification_preference = Int16(newPreference)
        }
        
        helper.saveMOC(moc: moc)
    }
    
    func updateNotificationTime(for contact: SelectedContact, hour: Int, minute: Int, moc: NSManagedObjectContext) {
        let newHour = hour
        let newMinute = minute
        moc.performAndWait {
            contact.notification_preference_hour = Int16(newHour)
            contact.notification_preference_minute = Int16(newMinute)
        }
        
        helper.saveMOC(moc: moc)
    }
    
    func updateNotificationPreferenceWeekday(for contact: SelectedContact, weekday: Int, moc: NSManagedObjectContext) {
        let newWeekday = weekday
        moc.performAndWait {
            contact.notification_preference_weekday = Int16(newWeekday)
        }
        print(contact.notification_preference_weekday)
        
        helper.saveMOC(moc: moc)
    }
    
    func updateNotificationCustomDate(for contact: SelectedContact, month: Int, day: Int, year: Int, moc: NSManagedObjectContext) {
        let customMonth = month
        let customDay = day
        let customYear = year
        moc.performAndWait {
            contact.notification_preference_custom_month = Int16(customMonth)
            contact.notification_preference_custom_day = Int16(customDay)
            contact.notification_preference_custom_year = Int16(customYear)
        }
        
        helper.saveMOC(moc: moc)
    }
    
    func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("User authorized CatchUp to send notifications")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func removeExistingNotifications(for contact: SelectedContact) {
        removeGeneralNotification(for: contact)
        
        if contactService.contactHasBirthday(contact) {
            removeBirthdayNotification(for: contact)
        }
        
        if contactService.contactHasAnniversary(contact) {
            removeAnniversaryNotification(for: contact)
        }
    }
    
    func removeGeneralNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.notification_identifier.uuidString])
        print("removed general notifications with id \(contact.notification_identifier)")
    }
    
    func removeBirthdayNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.birthday_notification_id.uuidString])
        print("removed birthday notification with id \(contact.birthday_notification_id)")
    }
    
    func removeAnniversaryNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.anniversary_notification_id.uuidString])
        print("removed anniversary notification with id \(contact.anniversary_notification_id)")
    }
}
