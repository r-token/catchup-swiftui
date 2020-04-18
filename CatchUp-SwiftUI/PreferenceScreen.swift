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
	var dayOptions = ["Sun", "Mon", "Tues", "Wed", "Thur", "Fri", "Sat"]
	var contact: SelectedContact
	
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
				self.removeExistingNotifications(for: self.contact)
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
						self.updateNotificationTime(hour: components.hour!, minute: components.minute!)
						self.createNewNotification(for: self.contact)
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
								print("weekday: \(weekday)")
								self.updateNotificationPreferenceWeekday(weekday: weekday)
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
									self.updateNotificationCustomDate(month: month, day: day, year: year)
									self.createNewNotification(for: self.contact)
								}
							
							Spacer()
						}
					}
				}
			}
			
			Spacer()
        }
		.padding(8)
		
		.onAppear(perform: requestAuthorizationForNotifications)
    }
	
	func removeExistingNotifications(for contact: SelectedContact) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.notification_identifier.uuidString, contact.birthday_notification_id.uuidString, contact.anniversary_notification_id.uuidString])
		
		print("removed general notifications with id \(contact.notification_identifier)")
		print("removed birthday notificaiton with id \(contact.birthday_notification_id)")
		print("removed annivesary notification with id \(contact.anniversary_notification_id)")
	}
	
	func createNewNotification(for contact: SelectedContact) {
		let notificationCenter = UNUserNotificationCenter.current()

		let addRequest = {
			
			let content = UNMutableNotificationContent()
			content.title = "👋 CatchUp with \(contact.name)"
			content.subtitle = "It's time to get back in touch with \(contact.name)"
			content.sound = UNNotificationSound.default

			let identifier = UUID()
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
			
			if contact.notification_preference != 0 {
				let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

				let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
				
				self.managedObjectContext.performAndWait {
					contact.notification_identifier = identifier
				}
				
				do {
					try self.managedObjectContext.save()
				} catch let error as NSError {
					print("Could not update the notification ID. \(error), \(error.userInfo)")
				}
				
				notificationCenter.add(request)
				print("Notification scheduled for \(dateComponents), and notification ID updated to \(contact.notification_identifier)")
			}
			
			var birthdayDateComponents = DateComponents()
			if contact.birthday != "" {
				let content = UNMutableNotificationContent()
				content.title = "🎂 It's \(contact.name)'s birthday!"
				content.subtitle = "Be sure to CatchUp and wish them a great one!"
				content.sound = UNNotificationSound.default

				let identifier = UUID()
				
				let month = (contact.birthday).prefix(2)
				let day = (contact.birthday).suffix(2)
				
				birthdayDateComponents.month = Int(month)
				birthdayDateComponents.day = Int(day)
				birthdayDateComponents.hour = 7
				birthdayDateComponents.minute = 15
				
				let trigger = UNCalendarNotificationTrigger(dateMatching: birthdayDateComponents, repeats: true)

				let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
				
				self.managedObjectContext.performAndWait {
					contact.birthday_notification_id = identifier
				}
				
				do {
					try self.managedObjectContext.save()
				} catch let error as NSError {
					print("Could not update the notification ID. \(error), \(error.userInfo)")
				}
				
				notificationCenter.add(request)
				print("Birthday notification scheduled for \(birthdayDateComponents), and birthday ID updated to \(contact.birthday_notification_id)")
			}
			
			var anniversaryDateComponents = DateComponents()
			if contact.anniversary != "" {
				let content = UNMutableNotificationContent()
				content.title = "😍 Tomorrow is \(contact.name)'s anniversary!"
				content.subtitle = "Be sure to CatchUp and wish them the best."
				content.sound = UNNotificationSound.default

				let identifier = UUID()
				
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
				
				let trigger = UNCalendarNotificationTrigger(dateMatching: anniversaryDateComponents, repeats: true)

				let request = UNNotificationRequest(identifier: identifier.uuidString, content: content, trigger: trigger)
				
				self.managedObjectContext.performAndWait {
					contact.anniversary_notification_id = identifier
				}
				
				do {
					try self.managedObjectContext.save()
				} catch let error as NSError {
					print("Could not update the anniversary notification ID. \(error), \(error.userInfo)")
				}
				
				notificationCenter.add(request)
				print("Annivesary notification scheduled for \(anniversaryDateComponents), and anniversary ID updated to \(contact.anniversary_notification_id)")
			}
		}

		notificationCenter.getNotificationSettings { settings in
			if settings.authorizationStatus == .authorized {
				addRequest()
			} else {
				notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
					if success {
						addRequest()
					} else {
						print("User isn't allowing notifications :(")
					}
				}
			}
		}
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
	
	func updateNotificationCustomDate(month: Int, day: Int, year: Int) {
		let customMonth = month
		let customDay = day
		let customYear = year
		managedObjectContext.performAndWait {
			contact.notification_preference_custom_month = Int16(customMonth)
			contact.notification_preference_custom_day = Int16(customDay)
			contact.notification_preference_custom_year = Int16(customYear)
		}
		
		do {
			try managedObjectContext.save()
			print("Custom date updated to \(contact.notification_preference_custom_month) / \(contact.notification_preference_custom_day) / \(contact.notification_preference_custom_year)")
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
