//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
	@State private var showingPreferenceScreen = false
	@Environment(\.managedObjectContext) var managedObjectContext
    
    let notificationService = NotificationService()
	let converter = Conversions()
	let contact: SelectedContact
	
    var body: some View {
		VStack {
			GradientView()
				.edgesIgnoringSafeArea(.top)
				.frame(height: 75)
			
			ContactPhoto(image: self.getContactPicture(from: contact.picture))
				.offset(x: 0, y: -130)
				.padding(.bottom, -130)
			
			VStack(alignment: .center, spacing: 10) {
				Text(contact.name)
					.font(.largeTitle)
					.bold()
				HStack(spacing: 0) {
					Text("Preference: ")
						.foregroundColor(.gray)
					Text(converter.convertNotificationPreferenceIntToString(preference: Int(contact.notification_preference), contact: contact))
						.foregroundColor(.gray)
				}
				Button(action: {
					self.showingPreferenceScreen = true
                }) {
                    Text("Change Notification Preference")
                        .font(.headline)
						.foregroundColor(.orange)
                }
			}
			
			List {
				if contact.phone != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Phone")
							.font(.caption)
						
						Button(contact.phone) {
							UIApplication.shared.open(self.getTappablePhoneNumber(from: self.contact.phone))
						}
						.foregroundColor(.blue)
					}
				}
				if contact.secondary_phone != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Phone")
							.font(.caption)
						
						Button(contact.secondary_phone) {
							UIApplication.shared.open(self.getTappablePhoneNumber(from: self.contact.secondary_phone))
						}
						.foregroundColor(.blue)
					}
				}
				if contact.email != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Email")
							.font(.caption)
						
						Button(contact.email) {
							UIApplication.shared.open(self.getTappableEmail(from: self.contact.email))
						}
						.foregroundColor(.blue)
					}
				}
				if contact.secondary_email != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Email")
							.font(.caption)
						
						Button(contact.secondary_email) {
							UIApplication.shared.open(self.getTappableEmail(from: self.contact.secondary_email))
						}
						.foregroundColor(.blue)
					}
				}
				if contact.address != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Address")
							.font(.caption)
						Text(contact.address)
					}
				}
				if contact.secondary_address != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Address")
							.font(.caption)
						Text(contact.secondary_address)
					}
				}
				if contact.birthday != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Birthday")
							.font(.caption)
						Text(contact.birthday)
					}
				}
				if contact.anniversary != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Anniversary")
							.font(.caption)
						Text(contact.anniversary)
					}
				}
			}
			
			Spacer()
		}
        .sheet(
			isPresented: $showingPreferenceScreen,
			onDismiss: {
				self.removeExistingNotifications(for: self.contact)
				self.createNewNotification(for: self.contact)
			}) {
				
			// the fact that I have to manually pass in the MOC is dumb
			// hopefully this is a SwiftUI v1 bug that's fixed at WWDC this year
			// (https://stackoverflow.com/questions/58328201/saving-core-data-entity-in-popover-in-swiftui-throws-nilerror-without-passing-e)
			PreferenceScreen(contact: self.contact).environment(\.managedObjectContext, self.managedObjectContext)
		}
		.onAppear(perform: clearBadge)
    }
	
	func getContactPicture(from string: String) -> Image {
		let imageData = NSData(base64Encoded: string)
		let uiImage = UIImage(data: imageData! as Data)!
		let image = Image(uiImage: uiImage)
		return image
	}
	
	func getTappablePhoneNumber(from phoneNumber: String) -> URL {
		let tel = "tel://"
		let cleanNumber = phoneNumber.replacingOccurrences(of: "[^\\d+]", with: "", options: [.regularExpression])
		let formattedString = tel + cleanNumber
		let tappableNumber = URL(string: formattedString)!
		
		return tappableNumber
	}
	
	func getTappableEmail(from emailAddress: String) -> URL {
		let mailto = "mailto:"
		let formattedString = mailto + emailAddress
		let tappableEmail = URL(string: formattedString)!
		
		return tappableEmail
	}
	
	func clearBadge() {
		UIApplication.shared.applicationIconBadgeNumber = 0
	}
	
	func removeExistingNotifications(for contact: SelectedContact) {
		UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.notification_identifier.uuidString, contact.birthday_notification_id.uuidString, contact.anniversary_notification_id.uuidString])
		
		print("removed general notifications with id \(contact.notification_identifier)")
		print("removed birthday notification with id \(contact.birthday_notification_id)")
		print("removed annivesary notification with id \(contact.anniversary_notification_id)")
	}
    
    func createNewNotification(for contact: SelectedContact) {
        let notificationCenter = UNUserNotificationCenter.current()

        let addRequest = {
            
            let content = UNMutableNotificationContent()
            content.title = "🎗️ CatchUp with \(contact.name)"
            content.body = self.notificationService.generateRandomNotificationSubtitle()
            content.sound = UNNotificationSound.default
            content.badge = 1

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
                content.title = "🎂 Today is \(contact.name)'s birthday!"
                content.body = "Be sure to CatchUp and wish them a great one!"
                content.sound = UNNotificationSound.default
                content.badge = 1

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
                content.body = "Be sure to CatchUp and wish them the best."
                content.sound = UNNotificationSound.default
                content.badge = 1

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
}
