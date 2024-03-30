//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
    @Environment(\.modelContext) var modelContext
    
    @Bindable var contact: SelectedContact

    var body: some View {
		VStack {
			GradientView()
				.edgesIgnoringSafeArea(.top)
				.frame(height: 75)
			
            ContactPhoto(image: Converter.getContactPicture(from: contact.picture))
				.offset(x: 0, y: -110)
				.padding(.bottom, -110)

            NameAndPreferenceStack(contact: contact)

            List {
                Section("Notification Preference") {
                    NotificationPreferenceView(contact: contact)
                }
                Section("Contact Information") {
                    ContactInfoView(contact: contact)
                }
            }
		}
        .onAppear {
            Utils.clearNotificationBadge()
        }

        .onDisappear {
            NotificationHelper.removeExistingNotifications(for: contact)
            NotificationHelper.createNewNotification(for: contact, modelContext: modelContext)
        }

        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailScreen(contact: SelectedContact.sampleData)
}
