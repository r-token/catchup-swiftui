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
	@Environment(\.modelContext) var modelContext

    let notificationService = NotificationService()
	let converter = Conversions()
    let helper = GeneralHelpers()
    let contactService = ContactService()
    
    @Bindable var contact: SelectedContact

    var formattedPrimaryPhoneNumber: String {
        converter.getFormattedPhoneNumber(from: contact.phone)
    }

    var formattedSecondaryPhoneNumber: String {
        converter.getFormattedPhoneNumber(from: contact.secondary_phone)
    }

    var tappablePrimaryPhoneNumber: URL {
        converter.getTappablePhoneNumber(from: contact.phone)
    }

    var tappableSecondaryPhoneNumber: URL {
        converter.getTappablePhoneNumber(from: contact.secondary_phone)
    }

    var tappablePrimaryEmail: URL {
        converter.getTappablePhoneNumber(from: contact.email)
    }

    var tappableSecondaryEmail: URL {
        converter.getTappablePhoneNumber(from: contact.secondary_email)
    }

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
                Section(header: Text("Contact Information")) {
                    if contactService.contactHasPhone(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Phone")
                                .font(.caption)
                            
                            Button(formattedPrimaryPhoneNumber) {
                                UIApplication.shared.open(tappablePrimaryPhoneNumber)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if contactService.contactHasSecondaryPhone(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Secondary Phone")
                                .font(.caption)
                            
                            Button(formattedSecondaryPhoneNumber) {
                                UIApplication.shared.open(tappableSecondaryPhoneNumber)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if contactService.contactHasEmail(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Email")
                                .font(.caption)
                            
                            Button(contact.email) {
                                UIApplication.shared.open(tappablePrimaryEmail)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if contactService.contactHasSecondaryEmail(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Secondary Email")
                                .font(.caption)
                            
                            Button(contact.secondary_email) {
                                UIApplication.shared.open(tappableSecondaryEmail)
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
                            Text(converter.getFormattedBirthdayOrAnniversary(from: contact.birthday))
                        }
                    }
                    if notificationService.contactHasAnniversary(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Anniversary")
                                .font(.caption)
                            Text(converter.getFormattedBirthdayOrAnniversary(from: contact.anniversary))
                        }
                    }
                }
			}
		}
        .sheet(
			isPresented: $showingPreferenceScreen,
			onDismiss: {
                self.notificationService.removeExistingNotifications(for: contact)
                self.notificationService.createNewNotification(for: contact, modelContext: modelContext)
			}) {
			PreferenceScreen(contact: contact)
		}
        .onAppear(perform: helper.clearNotificationBadge)
    }
}
