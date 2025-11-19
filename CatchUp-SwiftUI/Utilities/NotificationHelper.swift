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

/// Actor to serialize notification reset operations and prevent race conditions
actor NotificationResetGate {
    static let shared = NotificationResetGate()
    private var isResetting = false
    
    func runExclusive<T>(_ operation: @Sendable () async -> T) async -> T {
        while isResetting {
            try? await Task.sleep(for: .milliseconds(50))
        }
        isResetting = true
        defer { isResetting = false }
        return await operation()
    }
}

struct NotificationHelper {
    @MainActor
    static func createNewNotification(for contact: SelectedContact) async {
        // If there's nothing to schedule, short-circuit early
        if contact.preferenceIsNever() && !contact.hasBirthday() && !contact.hasAnniversary() {
            contact.next_notification_date_time = ""
            return
        }

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

    @MainActor
    static func preferenceIsNotSetToNever(for contact: SelectedContact) -> Bool {
        return contact.notification_preference != 0 ? true : false
    }

    @MainActor
    static func addGeneralNotification(for contact: SelectedContact) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = "👋 CatchUp with \(contact.name)"
        notificationContent.body = generateRandomNotificationBody()
        notificationContent.sound = UNNotificationSound.default
        notificationContent.badge = 1

        let identifier = NotificationID.general(contact)
        
        if contact.preferenceIsQuarterly() {
            // Quarterly uses time interval trigger
            let oneDay: Double = 86400
            let timeInterval = oneDay * 90
            scheduleNotification(
                for: contact,
                isBirthdayOrAnniversary: false,
                dateComponents: nil,
                timeInterval: timeInterval,
                identifier: identifier,
                content: notificationContent
            )
        } else {
            // All other preferences use calendar trigger
            let dateComponents = getNotificationDateComponents(for: contact)
            scheduleNotification(
                for: contact,
                isBirthdayOrAnniversary: false,
                dateComponents: dateComponents,
                timeInterval: nil,
                identifier: identifier,
                content: notificationContent
            )
        }
    }

    @MainActor
    static func addBirthdayNotification(for contact: SelectedContact) {
        let birthdayNotificationContent = UNMutableNotificationContent()
        birthdayNotificationContent.title = "🥳 Today is \(contact.name)'s birthday!"
        birthdayNotificationContent.body = "Be sure to CatchUp and wish them a great one!"
        birthdayNotificationContent.sound = UNNotificationSound.default
        birthdayNotificationContent.badge = 1

        let birthdayIdentifier = NotificationID.birthday(contact)
        let birthdayDateComponents = getBirthdayDateComponents(for: contact)

        scheduleNotification(
            for: contact,
            isBirthdayOrAnniversary: true,
            dateComponents: birthdayDateComponents,
            timeInterval: nil,
            identifier: birthdayIdentifier,
            content: birthdayNotificationContent
        )
    }

    @MainActor
    static func addAnniversaryNotification(for contact: SelectedContact) {
        let anniversaryNotificationContent = UNMutableNotificationContent()
        anniversaryNotificationContent.title = "😍 Tomorrow is \(contact.name)'s anniversary!"
        anniversaryNotificationContent.body = "Be sure to CatchUp and wish them the best."
        anniversaryNotificationContent.sound = UNNotificationSound.default
        anniversaryNotificationContent.badge = 1

        let anniversaryIdentifier = NotificationID.anniversary(contact)
        let anniversaryDateComponents = getAnniversaryDateComponents(for: contact)

        scheduleNotification(
            for: contact,
            isBirthdayOrAnniversary: true,
            dateComponents: anniversaryDateComponents,
            timeInterval: nil,
            identifier: anniversaryIdentifier,
            content: anniversaryNotificationContent
        )
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

    @MainActor
    static func getNextNotificationDateFor(contact: SelectedContact) -> String {
        // Early return for Never preference, only checking birthday/anniversary
        if contact.preferenceIsNever() {
            var soonest = ""
            if contact.hasBirthday() {
                let birthday = calculateDateStringFromComponents(getBirthdayDateComponents(for: contact))
                soonest = birthday
            }
            if contact.hasAnniversary() {
                let anniversary = calculateDateStringFromComponents(getAnniversaryDateComponents(for: contact))
                if soonest.isEmpty || anniversary < soonest {
                    soonest = anniversary
                }
            }
            return soonest
        }

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

    @MainActor
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

    @MainActor
    static func getNextNotificationDateForQuarterlyPreference(contact: SelectedContact) -> String {
        // Compute the next quarterly fire date without side effects
        let anchor = contact.notification_preference_quarterly_set_time
        let next = nextQuarterlyFireDate(from: anchor)
        return calculateDateStringFromDate(next)
    }

    @MainActor
    static func nextQuarterlyFireDate(from anchor: Date, now: Date = Date()) -> Date {
        let ninetyDays = Constants.ninetyDaysInSeconds
        let elapsed = now.timeIntervalSince(anchor)
        
        // If anchor is in the future, return it
        guard elapsed > 0 else { return anchor }
        
        // Calculate how many quarters have passed and add one more to get the next future date
        let quartersElapsed = ceil(elapsed / ninetyDays)
        return anchor.addingTimeInterval(quartersElapsed * ninetyDays)
    }

    @MainActor
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

    @MainActor
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

    @MainActor
    static func scheduleNotification(
        for contact: SelectedContact,
        isBirthdayOrAnniversary: Bool,
        dateComponents: DateComponents?,
        timeInterval: TimeInterval?,
        identifier: String,
        content: UNMutableNotificationContent
    ) {
        // Set thread and category identifiers for grouping and filtering
        content.threadIdentifier = NotificationID.thread(contact)
        
        if content.title.hasPrefix("👋") {
            content.categoryIdentifier = "catchup.general"
        } else if content.title.hasPrefix("🥳") {
            content.categoryIdentifier = "catchup.birthday"
        } else {
            content.categoryIdentifier = "catchup.anniversary"
        }
        
        // Create the appropriate trigger
        let trigger: UNNotificationTrigger
        if let timeInterval {
            trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: true)
        } else if let dateComponents {
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        } else {
            assertionFailure("Missing trigger for notification")
            return
        }
        
        // Create and add the request with stable identifier
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
        
        // Keep legacy UUID fields updated for backwards compatibility (but don't use them for scheduling)
        if content.title.hasPrefix("👋") {
            contact.notification_identifier = UUID(uuidString: identifier.split(separator: ".").last.map(String.init) ?? "") ?? UUID()
        } else if content.title.hasPrefix("🥳") {
            contact.birthday_notification_id = UUID(uuidString: identifier.split(separator: ".").last.map(String.init) ?? "") ?? UUID()
        } else {
            contact.anniversary_notification_id = UUID(uuidString: identifier.split(separator: ".").last.map(String.init) ?? "") ?? UUID()
        }
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

    @MainActor
    static func updateNotificationPreference(for contact: SelectedContact, selection: Int) {
        contact.notification_preference = selection
    }

    @MainActor
    static func updateNotificationTime(for contact: SelectedContact, hour: Int, minute: Int) {
        contact.notification_preference_hour = hour
        contact.notification_preference_minute = minute
    }

    @MainActor
    static func updateNotificationPreferenceWeekday(for contact: SelectedContact, weekday: Int) {
        contact.notification_preference_weekday = weekday
    }

    @MainActor
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

    @MainActor
    static func removeExistingNotifications(for contact: SelectedContact) {
        removeGeneralNotification(for: contact)
        
        if contact.hasBirthday() {
            removeBirthdayNotification(for: contact)
        }
        
        if contact.hasAnniversary() {
            removeAnniversaryNotification(for: contact)
        }
    }

    @MainActor
    static func removeGeneralNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.notification_identifier.uuidString])

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Pending requests after removing existing request: \(requests.count)")
        }
    }

    @MainActor
    static func removeBirthdayNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.birthday_notification_id.uuidString])
    }

    @MainActor
    static func removeAnniversaryNotification(for contact: SelectedContact) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.anniversary_notification_id.uuidString])
    }

    @MainActor
    static func updateNextNotificationDateTimeFor(contact: SelectedContact) {
        let nextNotificationDateTime = getNextNotificationDateFor(contact: contact)
        contact.next_notification_date_time = nextNotificationDateTime
    }

    static func getDateComponentsFromDate(_ date: Date) -> DateComponents {
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date)
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

    @MainActor
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
    
    /// Purges all pending notifications for a contact, including legacy identifiers
    /// This handles:
    /// - Stable identifiers (general/birthday/anniversary)
    /// - Legacy UUID-based identifiers
    /// - Thread-based identifiers
    /// - Title-based matching for old notifications
    static func purgePendingForContact(_ contact: SelectedContact) async {
        // Capture all needed values from contact before entering closure
        let contactName = contact.name
        let threadId = NotificationID.thread(contact)
        let generalId = NotificationID.general(contact)
        let birthdayId = NotificationID.birthday(contact)
        let anniversaryId = NotificationID.anniversary(contact)
        let legacyNotificationId = contact.notification_identifier.uuidString
        let legacyBirthdayId = contact.birthday_notification_id.uuidString
        let legacyAnniversaryId = contact.anniversary_notification_id.uuidString
        
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            UNUserNotificationCenter.current().getPendingNotificationRequests { allPending in
                // Get all existing notification identifiers for this contact
                let existingIds = Set(allPending.map(\.identifier))
                
                // Title-based matching for legacy notifications
                let titles = [
                    "👋 CatchUp with \(contactName)",
                    "🥳 Today is \(contactName)'s birthday!",
                    "😍 Tomorrow is \(contactName)'s anniversary!"
                ]
                
                // Build candidate identifiers (stable + legacy)
                let candidateIds = [
                    generalId,
                    birthdayId,
                    anniversaryId,
                    legacyNotificationId,
                    legacyBirthdayId,
                    legacyAnniversaryId
                ]
                
                // Only include identifiers that actually exist, plus thread/title matches
                let targetIdentifiers = Set(
                    candidateIds.filter { existingIds.contains($0) }
                    + allPending.filter { $0.content.threadIdentifier == threadId }.map(\.identifier)
                    + allPending.filter { titles.contains($0.content.title) }.map(\.identifier)
                )
                
                if !targetIdentifiers.isEmpty {
                    UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: Array(targetIdentifiers))
                }
                
                continuation.resume()
            }
        }
    }

    /// One-time migration to clean up all legacy notifications
    @MainActor
    static func migrateLegacyNotifications() async {
        await withCheckedContinuation { (continuation: CheckedContinuation<Void, Never>) in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                // Find notifications without threadIdentifier (legacy)
                let legacyNotifications = requests.filter { $0.content.threadIdentifier.isEmpty }
                
                if !legacyNotifications.isEmpty {
                    // Nuclear option: remove everything to clean up legacy notifications
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                }
                
                continuation.resume()
            }
        }
        
        // Brief delay to ensure removal completes
        try? await Task.sleep(nanoseconds: 200_000_000) // 200ms
    }
    
    @MainActor
    static func resetNotifications(for selectedContacts: [SelectedContact], delayTime: Double) async {
        // Use actor gate to prevent concurrent resets
        await NotificationResetGate.shared.runExclusive {
            // Apply delay if specified (used on cold launch)
            if delayTime > 0 {
                try? await Task.sleep(for: .seconds(delayTime))
            }
        }
        
        // Now execute the reset on MainActor (outside the Sendable closure)
        let center = UNUserNotificationCenter.current()
        
        // Phase 1: Purge all existing notifications for each contact
        for contact in selectedContacts {
            await purgePendingForContact(contact)
        }
        
        // Phase 2: Re-schedule notifications with stable identifiers
        for contact in selectedContacts {
            if contact.notification_preference != 0 {
                await NotificationHelper.createNewNotification(for: contact)
            } else {
                // Ensure no general notification remains if user disabled it
                await center.remove([NotificationID.general(contact)])
            }
        }
        
        // Update unread badge times
        for contact in selectedContacts {
            if contact.unread_badge_date_time.isEmpty {
                contact.unread_badge_date_time = contact.next_notification_date_time
            }
        }
    }
}
