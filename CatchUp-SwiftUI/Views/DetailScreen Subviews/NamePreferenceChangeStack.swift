//
//  NamePreferenceChangeStack.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NamePreferenceChangeStack: View {
    @Environment(\.modelContext) var modelContext
    
    let contact: SelectedContact
    @Binding var isShowingPreferenceScreen: Bool

    var body: some View {
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
            .sheet(
                isPresented: $isShowingPreferenceScreen,
                onDismiss: {
                    NotificationHelper.removeExistingNotifications(for: contact)
                    NotificationHelper.createNewNotification(for: contact, modelContext: modelContext)
                }
            ) {
                PreferenceScreen(contact: contact)
            }
        }
    }
}

#Preview {
    NamePreferenceChangeStack(contact: SelectedContact.sampleData, isShowingPreferenceScreen: .constant(false))
}
