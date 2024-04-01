//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
    @Bindable var contact: SelectedContact

    var nextCatchUpTime: String {
        print("recalculating nextCatchUpTime")
        return ContactHelper.getFriendlyNextCatchUpTime(for: contact)
    }

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
                Section {
                    NextCatchUpRow(nextCatchUpTime: nextCatchUpTime)
                    BirthdayOrAnniversaryRow(contact: contact)
                }
                Section("Notification Preference") {
                    NotificationPreferenceView(contact: contact)
                }
                Section("Contact Information") {
                    ContactInfoView(contact: contact)
                }

                RemoveContactButton(contact: contact)
            }
		}
        .onAppear {
            Utils.clearNotificationBadge()
        }

        .onDisappear {
            NotificationHelper.removeExistingNotifications(for: contact)
            NotificationHelper.createNewNotification(for: contact)
        }

        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailScreen(contact: SelectedContact.sampleData)
}
