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
	@State private var dayChoice = 0
	@State private var notificationTime = Date()
	@State var notificationPreference: Int
	@Environment(\.managedObjectContext) var managedObjectContext
	
	let now = Date()
    var notificationOptions = ["Never", "Daily", "Weekly", "Monthly", "Custom"]
	var dayOptions = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
	var contact: SelectedContact
	
	// before using this init, I had notification preference initialized at 0
	// this caused the preference to reset back to 0 every time this sheet appeared
	// this is the only way I could find to pull in the user's current notification_preference from Core Data as the default for the picker
	// (https://stackoverflow.com/questions/60572944/swiftui-setting-initial-picker-value-from-coredata)
	init(contact: SelectedContact) {
		self.contact = contact
		
		self._notificationPreference = State<Int>(initialValue: Int(contact.notification_preference))
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
				
				// This [self.notificationPreference].publisher.first() BS
				// is not documented anywhere
				// found buried in comments on Stack Overflow.
				// But it works (https://stackoverflow.com/questions/58676483/is-there-a-way-to-call-a-function-when-a-swiftui-picker-selection-changes)
			.onReceive([self.notificationPreference].publisher.first()) { (value) in
				print(value)
				self.updateNotificationPreference(selection: value)
			}
			
			VStack(alignment: .leading, spacing: 20) {
				
				if notificationPreference != 0 && notificationPreference != 4 { // Daily, Weekly, or Monthly
					Text("What time?")
						.padding(.top)
					DatePicker("What time should we notify you?", selection: $notificationTime, displayedComponents: .hourAndMinute)
						.labelsHidden()
					
					if notificationPreference == 2 { // Weekly
						Text("What day?")
					}
					if notificationPreference == 3 { // Monthly
						Text("What day? We'll pick a random week of the month.")
					}
					
					if notificationPreference == 2 || notificationPreference == 3 {
						Picker(selection: $dayChoice, label: Text("Which day of the week?")) {
							ForEach(0..<dayOptions.count) { index in
								Text(self.dayOptions[index]).tag(index)
							}
						}.pickerStyle(SegmentedPickerStyle())
					}
				}
				
				if notificationPreference == 4 { // Yearly
					VStack(alignment: .leading, spacing: 20) {
						Text("When would you like to be notified?")
							.padding(.top)
						DatePicker("What day and time should we notify you?", selection: $notificationTime, in: Date()..., displayedComponents: .date)
							.labelsHidden()
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
