//
//  PreferenceScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import UserNotifications

struct PreferenceScreen: View {
	@State private var notificationPreference: Int
	@State private var notificationPreferenceTime: Date
	@State private var notificationPreferenceWeekday: Int
	@State private var notificationPreferenceCustomDate: Date
	@Environment(\.managedObjectContext) var managedObjectContext
	
	let now = Date()
    var notificationOptions = ["Never", "Daily", "Weekly", "Monthly", "Custom"]
	var dayOptions = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
	var contact: SelectedContact
	
	// set default values equal to their Core Data values
	// for new contacts who haven't been changed yet, many of these defaults are set in ContactPickerViewController.swift
	init(contact: SelectedContact) {
		let calendar = Calendar.current
		let dateComponents = DateComponents(calendar: calendar, hour: Int(contact.notification_preference_hour), minute: Int(contact.notification_preference_minute))
		let time = Calendar.current.date(from: dateComponents)
		
		self.contact = contact
		self._notificationPreference = State<Int>(initialValue: Int(contact.notification_preference))
		self._notificationPreferenceTime = State<Date>(initialValue: time!)
		self._notificationPreferenceWeekday = State<Int>(initialValue: Int(contact.notification_preference_weekday))
		self._notificationPreferenceCustomDate = State<Date>(initialValue: contact.notification_preference_customdate)
	}

    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			
			Text("Preference")
				.font(.largeTitle)
				.bold()
				.foregroundColor(.orange)
				.padding(.top)
				.padding(5)
			
			Text("How often should we notify you to CatchUp with \(contact.name)?")
				.padding(5)
			
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
				self.updateNotificationPreference(selection: preference)
			}
			
			VStack(alignment: .leading, spacing: 20) {
				
				if notificationPreference != 0 && notificationPreference != 4 { // Daily, Weekly, or Monthly
					Text("What time?")
						.padding(.top)
					
					DatePicker("What time should we notify you?", selection: $notificationPreferenceTime, displayedComponents: .hourAndMinute)
						.labelsHidden()
					
						.onReceive([self.notificationPreferenceTime].publisher.first()) { (datetime) in
							let calendar = Calendar.current
							let components = calendar.dateComponents([.hour, .minute], from : datetime)
							self.updateNotificationTime(hour: components.hour!, minute: components.minute!)
					}
					
					if notificationPreference == 2 { // Weekly
						Text("What day?")
					}
					if notificationPreference == 3 { // Monthly
						Text("What day? We'll pick a random week of the month.")
					}
					
					if notificationPreference == 2 || notificationPreference == 3 {
						Picker(selection: $notificationPreferenceWeekday, label: Text("Which day of the week?")) {
							ForEach(0..<dayOptions.count) { index in
								Text(self.dayOptions[index]).tag(index)
							}
						}.pickerStyle(SegmentedPickerStyle())
						
							.onReceive([self.notificationPreferenceWeekday].publisher.first()) { (weekday) in
								self.updateNotificationPreferenceWeekday(weekday: weekday)
							}
					}
				}
				
				if notificationPreference == 4 { // Yearly
					VStack(alignment: .leading, spacing: 20) {
						Text("When would you like to be notified?")
							.padding(.top)
						
						DatePicker("What day and time should we notify you?", selection: $notificationPreferenceCustomDate, in: Date()..., displayedComponents: .date)
							.labelsHidden()
						
							.onReceive([self.notificationPreferenceCustomDate].publisher.first()) { (date) in
								self.updateNotificationCustomDate(date: date)
							}
					}
				}
			}
			
			Spacer()
        }
		.padding(8)
		
		.onAppear(perform: requestAuthorizationForNotifications)
    }
	
	func addNotification(for contact: SelectedContact) {
		let notificationCenter = UNUserNotificationCenter.current()

		let addRequest = {
			let contactID = contact.id
			
			let content = UNMutableNotificationContent()
			content.title = "CatchUp with \(contact.name)"
			content.subtitle = "It's time to get back in touch with \(contact.name)"
			content.sound = UNNotificationSound.default

			var dateComponents = DateComponents()
			dateComponents.hour = 9
			let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)

			let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
			notificationCenter.add(request)
		}

		// more code to come
	}
	
	func updateNotificationPreference(selection: Int) {
		let newPreference = selection
		managedObjectContext.performAndWait {
			contact.notification_preference = Int16(newPreference)
		}
		
		do {
			try managedObjectContext.save()
			print("notification preference updated to \(contact.notification_preference)")
		} catch let error as NSError {
			print("Could not update the notification preference. \(error), \(error.userInfo)")
		}
	}
	
	func updateNotificationTime(hour: Int, minute: Int) {
		let newHour = hour
		let newMinute = minute
		managedObjectContext.performAndWait {
			contact.notification_preference_hour = Int16(newHour)
			contact.notification_preference_minute = Int16(newMinute)
		}
		
		do {
			try managedObjectContext.save()
			print("Hour updated to \(contact.notification_preference_hour)")
			print("Minute updated to \(contact.notification_preference_minute)")
		} catch let error as NSError {
			print("Could not update the notification time. \(error), \(error.userInfo)")
		}
	}
	
	func updateNotificationPreferenceWeekday(weekday: Int) {
		let newWeekday = weekday
		managedObjectContext.performAndWait {
			contact.notification_preference_weekday = Int16(newWeekday)
		}
		
		do {
			try managedObjectContext.save()
			print("notification weekday updated to \(contact.notification_preference_weekday)")
		} catch let error as NSError {
			print("Could not update the notification weekday. \(error), \(error.userInfo)")
		}
	}
	
	func updateNotificationCustomDate(date: Date) {
		let newDate = date
		managedObjectContext.performAndWait {
			contact.notification_preference_customdate = newDate
		}
		
		do {
			try managedObjectContext.save()
			print("Custom date updated to \(contact.notification_preference_customdate)")
		} catch let error as NSError {
			print("Could not update the custom date. \(error), \(error.userInfo)")
		}
	}
	
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
