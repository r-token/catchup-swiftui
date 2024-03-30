//
//  NotificationPreferenceView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/29/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NotificationPreferenceView: View {
    @Environment(\.modelContext) var modelContext

    @State private var notificationPreferenceTime = Date()
    @State private var notificationPreferenceCustomDate = Date()
    @State private var whatDayText = ""

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
            setInitialNotificateDateTime()
            
            if contact.notification_preference == 2 { // weekly
                whatDayText = "What day?"
            } else if contact.notification_preference == 3 { // monthly
                whatDayText = "What day? We'll pick a random week."
            }

            print("contact notification preference: \(contact.notification_preference)")
        }

        .onChange(of: contact.notification_preference) {
            if contact.notification_preference == 2 { // weekly
                whatDayText = "What day?"
            } else if contact.notification_preference == 3 { // monthly
                whatDayText = "What day? We'll pick a random week."
            }
        }

        .onChange(of: notificationPreferenceTime) { initialTime, newTime in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from : newTime)
            NotificationHelper.updateNotificationTime(for: contact, hour: components.hour!, minute: components.minute!, modelContext: modelContext)
        }

        .onChange(of: notificationPreferenceCustomDate) { initialDate, newDate in
            let year = Calendar.current.component(.year, from: newDate)
            let month = Calendar.current.component(.month, from: newDate)
            let day = Calendar.current.component(.day, from: newDate)
            NotificationHelper.updateNotificationCustomDate(for: contact, month: month, day: day, year: year, modelContext: modelContext)
        }
    }

    func setInitialNotificateDateTime() {
        let calendar = Calendar.current
        let timeComponents = DateComponents(calendar: calendar, hour: Int(contact.notification_preference_hour), minute: Int(contact.notification_preference_minute))
        let time = Calendar.current.date(from: timeComponents)

        let customDateComponents = DateComponents(calendar: calendar, year: Int(contact.notification_preference_custom_year), month: Int(contact.notification_preference_custom_month), day: Int(contact.notification_preference_custom_day))
        let customDate = Calendar.current.date(from: customDateComponents)

        notificationPreferenceTime = time ?? Date()
        notificationPreferenceCustomDate = customDate ?? Date()
    }
}

#Preview {
    NotificationPreferenceView(contact: SelectedContact.sampleData)
}
