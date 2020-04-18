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
	let contact: SelectedContact
	let converter = Conversions()
	
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
					Text(converter.convertNotificationPreferenceIntToString(preference: Int(contact.notification_preference), contact: contact))
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
		.sheet(isPresented: $showingPreferenceScreen) {
			// the fact that I have to manually pass in the MOC is dumb
			// hopefully this is a SwiftUI v1 bug that's fixed at WWDC this year
			// (https://stackoverflow.com/questions/58328201/saving-core-data-entity-in-popover-in-swiftui-throws-nilerror-without-passing-e)
			PreferenceScreen(contact: self.contact).environment(\.managedObjectContext, self.managedObjectContext)
		}
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
}
