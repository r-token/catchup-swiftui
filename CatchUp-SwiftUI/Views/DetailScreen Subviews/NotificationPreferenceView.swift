//
//  NotificationPreferenceView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/29/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NotificationPreferenceView: View {
    @Environment(DataController.self) var dataController
    @Environment(\.modelContext) var modelContext

    @State private var initialNotificationPreference = 0
    @State private var initialNotificationPreferenceWeekday = 0
    @State private var initialNotificationPreferenceTime = Date()
    @State private var initialNotificationPreferenceCustomDate = Date()

    @State private var notificationPreferenceTime = Date()
    @State private var notificationPreferenceCustomDate = Date()

    @State private var whatDayText = ""

    @Bindable var contact: SelectedContact

    let notificationOptions: [NotificationOption] = NotificationOption.allCases
    let dayOptions: [DayOption] = DayOption.allCases
    let monthOptions: [MonthOption] = MonthOption.allCases

    var body: some View {
        Group {
            // How Often picker
            Picker(selection: $contact.notification_preference, label: Text("How often?")) {
                ForEach(0..<notificationOptions.count, id: \.self) { index in
                    Text(notificationOptions[index].rawValue)
                }
            }

            if contact.preferenceIsDaily() {
                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            } else if contact.preferenceIsWeekly() || contact.preferenceIsMonthly() {
                // Day of the Week Picker
                Picker(selection: $contact.notification_preference_weekday, label: Text(whatDayText)) {
                    ForEach(0..<dayOptions.count, id: \.self) { index in
                        Text(dayOptions[index].rawValue).tag(index+1)
                    }
                }

                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            } else if contact.preferenceIsAnnually() {
                // Month Picker
                Picker(selection: $contact.notification_preference_custom_month, label: Text("What month?")) {
                    ForEach(0..<monthOptions.count, id: \.self) { index in
                        Text(monthOptions[index].rawValue).tag(index+1)
                    }
                }

                // Day Picker
                Picker(selection: $contact.notification_preference_custom_day, label: Text("What day?")) {
                    ForEach(1...28, id: \.self) { day in
                        Text("\(day)")
                    }
                }

                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            } else if contact.preferenceIsCustom() {
                HStack {
                    Text("When would you like to be notified?")

                    Spacer()

                    // Custom Date Picker
                    DatePicker(
                        "When would you like to be notified?",
                        selection: $notificationPreferenceCustomDate, in: Date()..., displayedComponents: .date
                    )
                    .labelsHidden()
                }

                TimePickerRow(notificationPreferenceTime: $notificationPreferenceTime)
            }
        }
        .onAppear {
            setInitialState()
        }

        .onChange(of: contact) {
            setInitialState()
        }

        .onChange(of: contact.notification_preference) { oldValue, newValue in
            if newValue != initialNotificationPreference {
                print("contact.notification_preference changed")
                initialNotificationPreference = 999

                if newValue == 2 { // weekly
                    whatDayText = "What day?"
                    contact.notification_preference_week_of_month = 0
                } else if newValue == 3 { // monthly
                    whatDayText = "What day? We'll pick a random week."
                    contact.notification_preference_week_of_month = .random(in: 2..<5)
                } else if newValue == 4 { // quarterly
                    contact.notification_preference_quarterly_set_time = Date()
                    print("scheduling quarterly time interval notification")
                } else if newValue == 5 { // annually
                    NotificationHelper.setYearPreference(for: contact)
                }

                resetNotificationsForContact()
            }
        }

        .onChange(of: contact.notification_preference_weekday) { initialValue, newValue in
            if newValue != initialNotificationPreferenceWeekday {
                initialNotificationPreferenceWeekday = 999
                resetNotificationsForContact()
            }
        }

        .onChange(of: contact.notification_preference_custom_month) {
            NotificationHelper.setYearPreference(for: contact)
            resetNotificationsForContact()
        }

        .onChange(of: contact.notification_preference_custom_day) {
            NotificationHelper.setYearPreference(for: contact)
            resetNotificationsForContact()
        }

        .onChange(of: notificationPreferenceTime) { initialTime, newTime in
            if newTime != initialNotificationPreferenceTime {
                initialNotificationPreferenceTime = Date()
                print("notificationPreferenceTime changed")
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from : newTime)
                
                if let hour = components.hour, let minute = components.minute {
                    NotificationHelper.setYearPreference(for: contact)
                    NotificationHelper.updateNotificationTime(for: contact, hour: hour, minute: minute)
                    resetNotificationsForContact()
                } else {
                    notificationPreferenceTime = initialTime
                }
            }
        }

        .onChange(of: notificationPreferenceCustomDate) { initialDate, newDate in
            if newDate != initialNotificationPreferenceCustomDate {
                initialNotificationPreferenceCustomDate = Date()
                print("notificationPreferenceCustomDate changed")
                let year = Calendar.current.component(.year, from: newDate)
                let month = Calendar.current.component(.month, from: newDate)
                let day = Calendar.current.component(.day, from: newDate)
                let hour = Calendar.current.component(.hour, from: notificationPreferenceTime)
                let minute = Calendar.current.component(.minute, from: notificationPreferenceTime)

                NotificationHelper.updateNotificationTime(for: contact, hour: hour, minute: minute)
                NotificationHelper.updateNotificationCustomDate(for: contact, month: month, day: day, year: year)

                resetNotificationsForContact()
            }
        }
    }

    func setInitialState() {
        dataController.selectedContact = contact
        setInitialNotificateDateTime()

        if contact.preferenceIsWeekly() {
            whatDayText = "What day?"
        } else if contact.preferenceIsMonthly() {
            whatDayText = "What day? We'll pick a random week."
        }

        Utils.clearUnreadBadge(for: contact)
    }

    func setInitialNotificateDateTime() {
        let calendar = Calendar.current
        let timeComponents = DateComponents(
            calendar: calendar,
            hour: contact.notification_preference_hour,
            minute: contact.notification_preference_minute
        )
        let time = Calendar.current.date(from: timeComponents)

        let customDateComponents = DateComponents(
            calendar: calendar,
            year: contact.notification_preference_custom_year,
            month: contact.notification_preference_custom_month,
            day: contact.notification_preference_custom_day
        )
        let customDate = Calendar.current.date(from: customDateComponents)

        initialNotificationPreference = contact.notification_preference
        initialNotificationPreferenceWeekday = contact.notification_preference_weekday
        initialNotificationPreferenceTime = time ?? Date()
        initialNotificationPreferenceCustomDate = customDate ?? Date()

        notificationPreferenceTime = time ?? Date()
        notificationPreferenceCustomDate = customDate ?? Date()
    }

    @MainActor
    func resetNotificationsForContact() {
        print("resetting notifications for \(contact.name)")
        NotificationHelper.removeExistingNotifications(for: contact)
        NotificationHelper.createNewNotification(for: contact)
    }
}

#Preview {
    NotificationPreferenceView(contact: SelectedContact.sampleData)
}
