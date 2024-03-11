//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
	@State private var isShowingPreferenceScreen = false
	@Environment(\.modelContext) var modelContext
    
    @Bindable var contact: SelectedContact

    var formattedPrimaryPhoneNumber: String {
        Converter.getFormattedPhoneNumber(from: contact.phone)
    }

    var formattedSecondaryPhoneNumber: String {
        Converter.getFormattedPhoneNumber(from: contact.secondary_phone)
    }

    var tappablePrimaryPhoneNumber: URL {
        Converter.getTappablePhoneNumber(from: contact.phone)
    }

    var tappableSecondaryPhoneNumber: URL {
        Converter.getTappablePhoneNumber(from: contact.secondary_phone)
    }

    var tappablePrimaryEmail: URL {
        Converter.getTappablePhoneNumber(from: contact.email)
    }

    var tappableSecondaryEmail: URL {
        Converter.getTappablePhoneNumber(from: contact.secondary_email)
    }

    var body: some View {
		VStack {
			GradientView()
				.edgesIgnoringSafeArea(.top)
				.frame(height: 75)
			
            ContactPhoto(image: Converter.getContactPicture(from: contact.picture))
				.offset(x: 0, y: -130)
				.padding(.bottom, -130)
			
			VStack(alignment: .center, spacing: 10) {
				Text(contact.name)
					.font(.largeTitle)
					.bold()
				HStack(spacing: 0) {
					Text("Preference: ")
						.foregroundColor(.gray)
					Text(Converter.convertNotificationPreferenceIntToString(preference: Int(contact.notification_preference), contact: contact))
						.foregroundColor(.gray)
				}
				Button {
                    isShowingPreferenceScreen = true
                } label: {
                    Text("Change Notification Preference")
                        .font(.headline)
						.foregroundColor(.orange)
                }
			}
			
			List {
                Section(header: Text("Contact Information")) {
                    if ContactHelper.contactHasPhone(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Phone")
                                .font(.caption)
                            
                            Button(formattedPrimaryPhoneNumber) {
                                UIApplication.shared.open(tappablePrimaryPhoneNumber)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if ContactHelper.contactHasSecondaryPhone(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Secondary Phone")
                                .font(.caption)
                            
                            Button(formattedSecondaryPhoneNumber) {
                                UIApplication.shared.open(tappableSecondaryPhoneNumber)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if ContactHelper.contactHasEmail(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Email")
                                .font(.caption)
                            
                            Button(contact.email) {
                                UIApplication.shared.open(tappablePrimaryEmail)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if ContactHelper.contactHasSecondaryEmail(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Secondary Email")
                                .font(.caption)
                            
                            Button(contact.secondary_email) {
                                UIApplication.shared.open(tappableSecondaryEmail)
                            }
                            .foregroundColor(.blue)
                        }
                    }
                    if ContactHelper.contactHasAddress(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Address")
                                .font(.caption)
                            Text(contact.address)
                        }
                    }
                    if ContactHelper.contactHasSecondaryAddress(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Secondary Address")
                                .font(.caption)
                            Text(contact.secondary_address)
                        }
                    }
                    if NotificationHelper.contactHasBirthday(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Birthday")
                                .font(.caption)
                            Text(Converter.getFormattedBirthdayOrAnniversary(from: contact.birthday))
                        }
                    }
                    if NotificationHelper.contactHasAnniversary(contact) {
                        VStack(alignment: .leading, spacing: 3) {
                            Text("Anniversary")
                                .font(.caption)
                            Text(Converter.getFormattedBirthdayOrAnniversary(from: contact.anniversary))
                        }
                    }
                }
			}
		}
        .sheet(
			isPresented: $isShowingPreferenceScreen,
			onDismiss: {
                NotificationHelper.removeExistingNotifications(for: contact)
                NotificationHelper.createNewNotification(for: contact, modelContext: modelContext)
			}) {
			PreferenceScreen(contact: contact)
		}
        .onAppear(perform: Utils.clearNotificationBadge)
    }
}
