//
//  NotificationPreferenceView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/29/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NotificationPreferenceView: View {
    @Environment(DataController.self) private var dataController

    @Bindable var contact: SelectedContact
    @Binding var shouldSetPreferenceViewState: Bool

    @State private var initialNotificationPreference = 0 // Never
    @State private var initialNotificationPreferenceWeekday = 1 // Sunday
    @State private var initialNotificationPreferenceTime = Date.now
    @State private var initialNotificationPreferenceCustomDate = Date.now

    @State private var notificationPreferenceTime = Date.now
    @State private var notificationPreferenceCustomDate = Date.now

    @State private var whatDayText = ""
    @State private var resetTask: Task<Void, Never>?

    private let notificationOptions = NotificationOption.allCases
    private let dayOptions = DayOption.allCases
    private let monthOptions = MonthOption.allCases

    var body: some View {
        Group {
            HowOftenPicker(
                selection: $contact.notification_preference,
                options: notificationOptions
            )

            if contact.preferenceIsDaily() {
                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            } else if contact.preferenceIsWeekly() || contact.preferenceIsMonthly() {
                WeekdayPicker(
                    selection: $contact.notification_preference_weekday,
                    label: whatDayText,
                    options: dayOptions
                )
                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            } else if contact.preferenceIsAnnually() {
                MonthPicker(
                    selection: $contact.notification_preference_custom_month,
                    options: monthOptions
                )
                DayOfMonthPicker(selection: $contact.notification_preference_custom_day)
                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            } else if contact.preferenceIsCustom() {
                CustomDatePicker(selection: $notificationPreferenceCustomDate)
                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            }
        }
        .onAppear {
            if shouldSetPreferenceViewState {
                shouldSetPreferenceViewState = false
                setInitialState()
            }
        }
        .onChange(of: contact) {
            setInitialState()
        }
        .onChange(of: contact.notification_preference) { _, newValue in
            handlePreferenceChange(newValue: newValue)
        }
        .onChange(of: contact.notification_preference_weekday) { _, newValue in
            handleWeekdayChange(newValue: newValue)
        }
        .onChange(of: contact.notification_preference_custom_month) {
            NotificationHelper.setYearPreference(for: contact)
            scheduleDebouncedReset(reason: "customMonth")
        }
        .onChange(of: contact.notification_preference_custom_day) {
            NotificationHelper.setYearPreference(for: contact)
            scheduleDebouncedReset(reason: "customDay")
        }
        .onChange(of: notificationPreferenceTime) { initialTime, newTime in
            handleTimeChange(initialTime: initialTime, newTime: newTime)
        }
        .onChange(of: notificationPreferenceCustomDate) { _, newDate in
            handleCustomDateChange(newDate: newDate)
        }
        .onDisappear {
            resetTask?.cancel()
        }
    }

    private func handlePreferenceChange(newValue: Int) {
        guard newValue != initialNotificationPreference else { return }
        print("contact.notification_preference changed")
        initialNotificationPreference = 999

        switch newValue {
        case 2: // weekly
            whatDayText = "What day?"
            contact.notification_preference_week_of_month = 0
        case 3: // monthly
            whatDayText = "What day? We'll pick a random week."
            contact.notification_preference_week_of_month = .random(in: 2..<5)
        case 4: // quarterly
            contact.notification_preference_quarterly_set_time = .now
            print("scheduling quarterly time interval notification")
        case 5: // annually
            NotificationHelper.setYearPreference(for: contact)
        default:
            break
        }

        scheduleDebouncedReset(reason: "preference")
    }

    private func handleWeekdayChange(newValue: Int) {
        guard newValue != initialNotificationPreferenceWeekday else { return }
        initialNotificationPreferenceWeekday = 999
        scheduleDebouncedReset(reason: "weekday")
    }

    private func handleTimeChange(initialTime: Date, newTime: Date) {
        guard newTime != initialNotificationPreferenceTime else { return }
        initialNotificationPreferenceTime = .now
        print("notificationPreferenceTime changed")
        let components = Calendar.current.dateComponents([.hour, .minute], from: newTime)

        guard let hour = components.hour, let minute = components.minute else {
            notificationPreferenceTime = initialTime
            return
        }
        NotificationHelper.setYearPreference(for: contact)
        NotificationHelper.updateNotificationTime(for: contact, hour: hour, minute: minute)
        scheduleDebouncedReset(reason: "time")
    }

    private func handleCustomDateChange(newDate: Date) {
        guard newDate != initialNotificationPreferenceCustomDate else { return }
        initialNotificationPreferenceCustomDate = .now
        print("notificationPreferenceCustomDate changed")
        let calendar = Calendar.current
        let year = calendar.component(.year, from: newDate)
        let month = calendar.component(.month, from: newDate)
        let day = calendar.component(.day, from: newDate)
        let hour = calendar.component(.hour, from: notificationPreferenceTime)
        let minute = calendar.component(.minute, from: notificationPreferenceTime)

        NotificationHelper.updateNotificationTime(for: contact, hour: hour, minute: minute)
        NotificationHelper.updateNotificationCustomDate(for: contact, month: month, day: day, year: year)
        scheduleDebouncedReset(reason: "customDate")
    }

    private func setInitialState() {
        dataController.selectedContact = contact
        setInitialNotificationDateTime()

        if contact.preferenceIsWeekly() {
            whatDayText = "What day?"
        } else if contact.preferenceIsMonthly() {
            whatDayText = "What day? We'll pick a random week."
        }

        Utils.clearUnreadBadge(for: contact)
    }

    private func setInitialNotificationDateTime() {
        let calendar = Calendar.current
        let timeComponents = DateComponents(
            calendar: calendar,
            hour: contact.notification_preference_hour,
            minute: contact.notification_preference_minute
        )
        let time = calendar.date(from: timeComponents) ?? .now

        let customDateComponents = DateComponents(
            calendar: calendar,
            year: contact.notification_preference_custom_year,
            month: contact.notification_preference_custom_month,
            day: contact.notification_preference_custom_day
        )
        let customDate = calendar.date(from: customDateComponents) ?? .now

        initialNotificationPreference = contact.notification_preference
        initialNotificationPreferenceWeekday = contact.notification_preference_weekday
        initialNotificationPreferenceTime = time
        initialNotificationPreferenceCustomDate = customDate

        notificationPreferenceTime = time
        notificationPreferenceCustomDate = customDate
    }

    private func scheduleDebouncedReset(reason: String) {
        // Cancel any in-flight reset when user continues editing
        resetTask?.cancel()
        resetTask = Task {
            // 300ms debounce to batch rapid changes
            try? await Task.sleep(for: .seconds(0.3))
            guard !Task.isCancelled else { return }
            await resetNotificationsForContact()
        }
    }

    private func resetNotificationsForContact() async {
        // Ensure we have authorization before scheduling
        let authorized = await NotificationHelper.checkNotificationAuthorizationStatusAndAddRequest()
        guard authorized else { return }

        // Remove only the general notification using stable identifier
        let center = UNUserNotificationCenter.current()
        await center.remove([NotificationID.general(contact)])

        // If not Never, schedule a new general notification with stable identifier
        if !contact.preferenceIsNever() {
            await NotificationHelper.addGeneralNotification(for: contact)
        }

        // Update the contact's next notification date string
        contact.next_notification_date_time = NotificationHelper.getNextNotificationDateFor(contact: contact)
    }
}

#Preview {
    NotificationPreferenceView(
        contact: .sampleData,
        shouldSetPreferenceViewState: .constant(true)
    )
    .environment(DataController())
}
