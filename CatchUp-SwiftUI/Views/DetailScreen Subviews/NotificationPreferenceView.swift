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
    @State private var viewDidAppear = false

    @Bindable var contact: SelectedContact

    let notificationOptions = ["Never", "Daily", "Weekly", "Monthly", "Custom"]
    let dayOptions = ["Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]

    var body: some View {
        Group {
            Picker(selection: $contact.notification_preference, label: Text("How often?")) {
                ForEach(0..<notificationOptions.count, id: \.self) { index in
                    Text(notificationOptions[index])
                }
            }

            if contact.notification_preference != 0 && contact.notification_preference != 4 { // Daily, Weekly, or Monthly
                if contact.notification_preference == 1 {
                    HStack {
                        Text("What time?")

                        Spacer()

                        DatePicker("What time?", selection: $notificationPreferenceTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }

                if contact.notification_preference == 2 || contact.notification_preference == 3 {
                    // Show Day of the Week Picker
                    Picker(selection: $contact.notification_preference_weekday, label: Text(whatDayText)) {
                        ForEach(0..<dayOptions.count, id: \.self) { index in
                            Text(dayOptions[index]).tag(index)
                        }
                    }

                    HStack {
                        Text("What time?")

                        Spacer()

                        DatePicker("What time?", selection: $notificationPreferenceTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()
                    }
                }
            }

            if contact.notification_preference == 4 { // Yearly
                HStack {
                    Text("When would you like to be notified?")

                    Spacer()

                    // Show Custom Date Picker
                    DatePicker("When would you like to be notified?", selection: $notificationPreferenceCustomDate, in: Date()..., displayedComponents: .date)
                        .labelsHidden()
                }
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
                contact.notification_preference_week_of_month = .random(in: 2..<5)

                if newValue == 2 { // weekly
                    whatDayText = "What day?"
                    contact.notification_preference_week_of_month = 0
                } else if newValue == 3 { // monthly
                    whatDayText = "What day? We'll pick a random week."
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

        .onChange(of: notificationPreferenceTime) { initialTime, newTime in
            if newTime != initialNotificationPreferenceTime {
                initialNotificationPreferenceTime = Date()
                print("notificationPreferenceTime changed")
                let calendar = Calendar.current
                let components = calendar.dateComponents([.hour, .minute], from : newTime)
                NotificationHelper.updateNotificationTime(for: contact, hour: components.hour!, minute: components.minute!)

                resetNotificationsForContact()
            }
        }

        .onChange(of: notificationPreferenceCustomDate) { initialDate, newDate in
            if newDate != initialNotificationPreferenceCustomDate {
                initialNotificationPreferenceCustomDate = Date()
                print("notificationPreferenceCustomDate changed")
                let year = Calendar.current.component(.year, from: newDate)
                let month = Calendar.current.component(.month, from: newDate)
                let day = Calendar.current.component(.day, from: newDate)
                NotificationHelper.updateNotificationCustomDate(for: contact, month: month, day: day, year: year)

                resetNotificationsForContact()
            }
        }
    }

    func setInitialState() {
        dataController.selectedContact = contact
        setInitialNotificateDateTime()

        if contact.notification_preference == 2 { // weekly
            whatDayText = "What day?"
        } else if contact.notification_preference == 3 { // monthly
            whatDayText = "What day? We'll pick a random week."
        }
    }

    func setInitialNotificateDateTime() {
        let calendar = Calendar.current
        let timeComponents = DateComponents(calendar: calendar, hour: Int(contact.notification_preference_hour), minute: Int(contact.notification_preference_minute))
        let time = Calendar.current.date(from: timeComponents)

        let customDateComponents = DateComponents(calendar: calendar, year: Int(contact.notification_preference_custom_year), month: Int(contact.notification_preference_custom_month), day: Int(contact.notification_preference_custom_day))
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
        NotificationHelper.updateNextNotificationDateTimeFor(contact: contact)
    }
}

#Preview {
    NotificationPreferenceView(contact: SelectedContact.sampleData)
}
