//
//  PreferenceScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct PreferenceScreen: View {
	@Environment(\.dismiss) var dismiss
	@Environment(\.modelContext) var modelContext

    @State private var notificationPreferenceTime = Date()
    @State private var notificationPreferenceCustomDate = Date()

    @Bindable var contact: SelectedContact

    let notificationService = NotificationService()
	let now = Date()

    var notificationOptions = ["Never", "Daily", "Weekly", "Monthly", "Custom"]
	var dayOptions = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Spacer()
                Button("Save") {
                    dismiss()
                }
                .foregroundColor(.blue)
                .font(.headline)
                .padding(.top)
                .padding(.trailing)
            }
            
            Text("Preference")
                .font(.largeTitle)
                .bold()
                .foregroundColor(.orange)
				.padding(.bottom)
            
            Text("How often should we notify you to CatchUp with \(contact.name)?")
            
            Picker(selection: $contact.notification_preference, label: Text("How often should we notify you to CatchUp with \(contact.name)?")) {
                ForEach(0..<notificationOptions.count, id: \.self) { index in
                    Text(notificationOptions[index])
                }
            }
            .pickerStyle(.segmented)
            .padding(.top)
            
            VStack(alignment: .leading, spacing: 20) {
                if contact.notification_preference != 0 && contact.notification_preference != 4 { // Daily, Weekly, or Monthly
                    Text("What time?")
                        .padding(.top)
                    
                    // Show the Time Picker
                    HStack(alignment: .center) {
                        Spacer()
                        
                        DatePicker("What time?", selection: $notificationPreferenceTime, displayedComponents: .hourAndMinute)
                            .labelsHidden()

                        Spacer()
                    }
                    
                    if contact.notification_preference == 2 { // Weekly
                        Text("What day?")
                    }

                    if contact.notification_preference == 3 { // Monthly
                        Text("What day? We'll pick a random week of the month.")
                            .lineLimit(nil)
                    }
                    
                    if contact.notification_preference == 2 || contact.notification_preference == 3 {
                        // Show Day of the Week Picker
                        Picker(selection: $contact.notification_preference_weekday, label: Text("What day?")) {
                            ForEach(0..<dayOptions.count, id: \.self) { index in
                                Text(self.dayOptions[index]).tag(index)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                    }
                }
                
                if contact.notification_preference == 4 { // Yearly
                    VStack(alignment: .leading, spacing: 20) {
                        Text("When would you like to be notified?")
                            .padding(.top)
                        
                        HStack {
                            Spacer()
                            
                            // Show Custom Date Picker
                            DatePicker("When would you like to be notified?", selection: $notificationPreferenceCustomDate, in: Date()..., displayedComponents: .date)
                                .labelsHidden()
                            
                            Spacer()
                        }
                    }
                }
            }
            Spacer()
        }
		.padding(15)

        .onAppear {
            notificationService.requestAuthorizationForNotifications()
            setInitialNotificateDateTime()

            print("contact notification preference: \(contact.notification_preference)")
        }

        .onChange(of: notificationPreferenceTime) { initialTime, newTime in
            let calendar = Calendar.current
            let components = calendar.dateComponents([.hour, .minute], from : newTime)
            notificationService.updateNotificationTime(for: contact, hour: components.hour!, minute: components.minute!, modelContext: modelContext)
        }

        .onChange(of: notificationPreferenceCustomDate) { initialDate, newDate in
            let year = Calendar.current.component(.year, from: newDate)
            let month = Calendar.current.component(.month, from: newDate)
            let day = Calendar.current.component(.day, from: newDate)
            notificationService.updateNotificationCustomDate(for: contact, month: month, day: day, year: year, modelContext: modelContext)
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
