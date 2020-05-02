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
    let helper = GeneralHelpers()
    let contactService = ContactService()
    
	let contact: SelectedContact
	
    var body: some View {
		VStack {
			GradientView()
				.edgesIgnoringSafeArea(.top)
				.frame(height: 75)
			
            ContactPhoto(image: self.converter.getContactPicture(from: contact.picture))
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
                if contactService.contactHasPhone(contact) {
					VStack(alignment: .leading, spacing: 3) {
						Text("Phone")
							.font(.caption)
						
                        Button(converter.getFormattedPhoneNumber(from: contact.phone)) {
                            UIApplication.shared.open(self.converter.getTappablePhoneNumber(from: self.contact.phone))
						}
						.foregroundColor(.blue)
					}
				}
                if contactService.contactHasSecondaryPhone(contact) {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Phone")
							.font(.caption)
						
                        Button(converter.getFormattedPhoneNumber(from: contact.secondary_phone)) {
                            UIApplication.shared.open(self.converter.getTappablePhoneNumber(from: self.contact.secondary_phone))
						}
						.foregroundColor(.blue)
					}
				}
                if contactService.contactHasEmail(contact) {
					VStack(alignment: .leading, spacing: 3) {
						Text("Email")
							.font(.caption)
						
						Button(contact.email) {
                            UIApplication.shared.open(self.converter.getTappableEmail(from: self.contact.email))
						}
						.foregroundColor(.blue)
					}
				}
                if contactService.contactHasSecondaryEmail(contact) {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Email")
							.font(.caption)
						
						Button(contact.secondary_email) {
                            UIApplication.shared.open(self.converter.getTappableEmail(from: self.contact.secondary_email))
						}
						.foregroundColor(.blue)
					}
				}
                if contactService.contactHasAddress(contact) {
					VStack(alignment: .leading, spacing: 3) {
						Text("Address")
							.font(.caption)
						Text(contact.address)
					}
				}
                if contactService.contactHasSecondaryAddress(contact) {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Address")
							.font(.caption)
						Text(contact.secondary_address)
					}
				}
                if notificationService.contactHasBirthday(contact) {
					VStack(alignment: .leading, spacing: 3) {
						Text("Birthday")
							.font(.caption)
						Text(contact.birthday)
					}
				}
                if notificationService.contactHasAnniversary(contact) {
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
                self.notificationService.removeExistingNotifications(for: self.contact)
                self.notificationService.createNewNotification(for: self.contact, moc: self.managedObjectContext)
			}) {
				
			// the fact that I have to manually pass in the MOC is dumb
			// hopefully this is a SwiftUI v1 bug that's fixed at WWDC this year
			// (https://stackoverflow.com/questions/58328201/saving-core-data-entity-in-popover-in-swiftui-throws-nilerror-without-passing-e)
			PreferenceScreen(contact: self.contact).environment(\.managedObjectContext, self.managedObjectContext)
		}
        .onAppear(perform: helper.clearNotificationBadge)
    }
}
