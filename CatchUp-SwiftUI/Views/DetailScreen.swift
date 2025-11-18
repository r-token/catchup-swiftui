//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
    @Environment(DataController.self) var dataController
    @Bindable var contact: SelectedContact

    @State private var shouldSetPreferenceViewState = true
    @State private var nextCatchUpTime: String = ""

    @MainActor
    private func refreshNextCatchUpTime() {
        nextCatchUpTime = ContactHelper.getFriendlyNextCatchUpTime(for: contact, forQuarterlyPreference: false)
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
                    NotificationPreferenceView(contact: contact, shouldSetPreferenceViewState: $shouldSetPreferenceViewState)
                }

                if contact.hasContactInfo() {
                    Section("Contact Information") {
                        ContactInfoView(contact: contact)
                    }
                }

                RemoveContactButton(contact: contact)
            }
		}
        .onAppear {
            Utils.clearAppIconNotificationBadge()
            Utils.clearUnreadBadge(for: contact)
            dataController.selectedContact = contact
            refreshNextCatchUpTime()
        }

        .onChange(of: contact.notification_preference) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_hour) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_minute) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_weekday) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_week_of_month) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_custom_day) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_custom_month) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_custom_year) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.notification_preference_quarterly_set_time) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.birthday) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.anniversary) { _, _ in refreshNextCatchUpTime() }
        .onChange(of: contact.next_notification_date_time) { _, _ in refreshNextCatchUpTime() }

        .onDisappear {
            dataController.selectedContact = nil
        }

        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    DetailScreen(contact: SelectedContact.sampleData)
}
