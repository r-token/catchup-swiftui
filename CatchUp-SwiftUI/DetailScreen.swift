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
	let contact: SelectedContact
	
    var body: some View {
		VStack {
			GradientView()
				.edgesIgnoringSafeArea(.top)
				.frame(height: 75)
			
			ContactPhoto(image: Image("DefaultPhoto"))
				.offset(x: 0, y: -130)
				.padding(.bottom, -130)
			
			VStack(alignment: .center, spacing: 10) {
				Text(contact.name)
					.font(.largeTitle)
					.bold()
				HStack {
					Text("Preference: ")
					Text(contact.notification_preference)
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
						Text(contact.phone)
					}
				}
				if contact.secondary_phone != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Phone")
							.font(.caption)
						Text(contact.secondary_phone)
					}
				}
				if contact.email != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Email")
							.font(.caption)
						Text(contact.email)
					}
				}
				if contact.secondary_email != "" {
					VStack(alignment: .leading, spacing: 3) {
						Text("Secondary Email")
							.font(.caption)
						Text(contact.secondary_email)
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
			PreferenceScreen(contact: self.contact)
		}
    }
}
