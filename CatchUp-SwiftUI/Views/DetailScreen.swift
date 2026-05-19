//
//  DetailScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct DetailScreen: View {
    @Environment(DataController.self) private var dataController
    @Bindable var contact: SelectedContact

    @State private var shouldSetPreferenceViewState = true
    @State private var nextCatchUpTime: String = ""

    var body: some View {
        VStack {
            GradientView()
                .ignoresSafeArea(edges: .top)
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
                    NotificationPreferenceView(
                        contact: contact,
                        shouldSetPreferenceViewState: $shouldSetPreferenceViewState
                    )
                }

                if contact.hasContactInfo() {
                    Section("Contact Information") {
                        ContactInfoView(contact: contact)
                    }
                }

                RemoveContactButton(contact: contact)
            }
        }
        .toolbarTitleDisplayMode(.inline)
        .onAppear {
            Utils.clearAppIconNotificationBadge()
            Utils.clearUnreadBadge(for: contact)
            dataController.selectedContact = contact
            refreshNextCatchUpTime()
        }
        .onDisappear {
            dataController.selectedContact = nil
        }
        .onChange(of: notificationStateSignature) {
            refreshNextCatchUpTime()
        }
    }

    @MainActor
    private func refreshNextCatchUpTime() {
        nextCatchUpTime = ContactHelper.getFriendlyNextCatchUpTime(for: contact, forQuarterlyPreference: false)
    }

    private var notificationStateSignature: String {
        [
            String(contact.notification_preference),
            String(contact.notification_preference_hour),
            String(contact.notification_preference_minute),
            String(contact.notification_preference_weekday),
            String(contact.notification_preference_week_of_month),
            String(contact.notification_preference_custom_day),
            String(contact.notification_preference_custom_month),
            String(contact.notification_preference_custom_year),
            contact.notification_preference_quarterly_set_time.description,
            contact.birthday,
            contact.anniversary,
            contact.next_notification_date_time
        ]
        .joined(separator: "|")
    }
}

#Preview {
    DetailScreen(contact: .sampleData)
        .environment(DataController())
}
