//
//  PreferenceScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct PreferenceScreen: View {
	@State private var notificationPreference: Int
	@State private var notificationPreferenceTime: Date
	@State private var notificationPreferenceWeekday: Int
	@State private var notificationPreferenceCustomDate: Date
	@Environment(\.presentationMode) var presentationMode
	@Environment(\.managedObjectContext) var managedObjectContext
	
    let notificationService = NotificationService()
	let now = Date()
    
	var contact: SelectedContact
    var notificationOptions = ["Never", "Daily", "Weekly", "Monthly", "Custom"]
	var dayOptions = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]
	
	// set default values equal to their Core Data values
	// for new contacts who haven't been changed yet, many of these defaults are set in ContactPickerViewController.swift
	init(contact: SelectedContact) {
		
		let calendar = Calendar.current
		let timeComponents = DateComponents(calendar: calendar, hour: Int(contact.notification_preference_hour), minute: Int(contact.notification_preference_minute))
		let time = Calendar.current.date(from: timeComponents)
		
		let customDateComponents = DateComponents(calendar: calendar, year: Int(contact.notification_preference_custom_year), month: Int(contact.notification_preference_custom_month), day: Int(contact.notification_preference_custom_day))
		let customDate = Calendar.current.date(from: customDateComponents)
		
		self.contact = contact
		self._notificationPreference = State<Int>(initialValue: Int(contact.notification_preference))
		self._notificationPreferenceTime = State<Date>(initialValue: time!)
		self._notificationPreferenceWeekday = State<Int>(initialValue: Int(contact.notification_preference_weekday))
		self._notificationPreferenceCustomDate = State<Date>(initialValue: customDate!)
	}

    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			
			HStack {
				Spacer()
				Button("Save") {
					self.presentationMode.wrappedValue.dismiss()
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
			
			Text("How often should we notify you to CatchUp with \(contact.name)?")
			
			Picker(selection: $notificationPreference, label: Text("How often should we notify you to CatchUp with \(contact.name)?")) {
                ForEach(0..<notificationOptions.count) { index in
                    Text(self.notificationOptions[index]).tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
				
			.padding(.top)
				
				// This [self.notificationPreference].publisher.first() BS is not documented anywhere.
				// Found it buried in comments on Stack Overflow. But it works.
				// (https://stackoverflow.com/questions/58676483/is-there-a-way-to-call-a-function-when-a-swiftui-picker-selection-changes)
			.onReceive([self.notificationPreference].publisher.first()) { (preference) in
                self.notificationService.updateNotificationPreference(for: self.contact, selection: preference, moc: self.managedObjectContext)
			}
			
			VStack(alignment: .leading, spacing: 20) {
				
				if notificationPreference != 0 && notificationPreference != 4 { // Daily, Weekly, or Monthly
					Text("What time?")
						.padding(.top)
					
					// Show the Time Picker
					HStack(alignment: .center) {
						Spacer()
						
						DatePicker("What time?", selection: $notificationPreferenceTime, displayedComponents: .hourAndMinute)
						.labelsHidden()
							
						Spacer()
							
						.onReceive([self.notificationPreferenceTime].publisher.first()) { (datetime) in
							let calendar = Calendar.current
							let components = calendar.dateComponents([.hour, .minute], from : datetime)
                            self.notificationService.updateNotificationTime(for: self.contact, hour: components.hour!, minute: components.minute!, moc: self.managedObjectContext)
						}
					
					}
					
					if notificationPreference == 2 { // Weekly
						Text("What day?")
					}
					if notificationPreference == 3 { // Monthly
						Text("What day? We'll pick a random week of the month.")
					}
					
					if notificationPreference == 2 || notificationPreference == 3 {
						
						// Show Day of the Week Picker
						Picker(selection: $notificationPreferenceWeekday, label: Text("What day?")) {
							ForEach(0..<dayOptions.count) { index in
								Text(self.dayOptions[index]).tag(index)
							}
						}.pickerStyle(SegmentedPickerStyle())
						
							.onReceive([self.notificationPreferenceWeekday].publisher.first()) { (weekday) in
                                self.notificationService.updateNotificationPreferenceWeekday(for: self.contact, weekday: weekday, moc: self.managedObjectContext)
							}
					}
				}
				
				if notificationPreference == 4 { // Yearly
					VStack(alignment: .leading, spacing: 20) {
						Text("When would you like to be notified?")
							.padding(.top)
						
						HStack {
							Spacer()
							
							// Show Custom Date Picker
							DatePicker("When would you like to be notified?", selection: $notificationPreferenceCustomDate, in: Date()..., displayedComponents: .date)
								.labelsHidden()
							
								.onReceive([self.notificationPreferenceCustomDate].publisher.first()) { (date) in
									let year = Calendar.current.component(.year, from: date)
									let month = Calendar.current.component(.month, from: date)
									let day = Calendar.current.component(.day, from: date)
									print("Received custom change")
                                    self.notificationService.updateNotificationCustomDate(for: self.contact, month: month, day: day, year: year, moc: self.managedObjectContext)
								}
							
							Spacer()
						}
					}
				}
			}
			
			Spacer()
        }
		.padding(15)
		
        .onAppear(perform: notificationService.requestAuthorizationForNotifications)
    }
}
