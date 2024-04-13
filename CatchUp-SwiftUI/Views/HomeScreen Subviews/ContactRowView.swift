//
//  ContactRowView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactRowView: View {
    @Environment(DataController.self) var dataController
    @Environment(\.scenePhase) var scenePhase
    let contact: SelectedContact

    @State private var shouldShowUnreadIndicator = false

    var body: some View {
        HStack {
            ContactPictureView(contact: contact)

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.headline)
                Text(Converter.convertNotificationPreferenceToString(contact: contact))
                    .font(.caption)

                    .if(Utils.isPhone()) { view in
                        view.foregroundStyle(.gray)
                    }
                    .if(Utils.isiPadOrMac()) { view in
                        view.foregroundStyle(dataController.selectedContact == contact ? .white : .gray)
                    }
            }

            Spacer()

            if shouldShowUnreadIndicator {
                Circle()
                    .foregroundStyle(.orange)
                    .frame(width: 15, height: 15)
                    .padding(.horizontal)
            }
        }
        .onAppear {
            shouldShowUnreadIndicator = determineIfShouldShowIndicator()
        }

        .onChange(of: scenePhase) {
            if scenePhase == .active {
                shouldShowUnreadIndicator = determineIfShouldShowIndicator()
            }
        }

        .onChange(of: dataController.selectedContact) {
            shouldShowUnreadIndicator = determineIfShouldShowIndicator()
        }
    }

    func determineIfShouldShowIndicator() -> Bool {
        let today = Date.now
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let formattedTodayDate = formatter.string(from: today)

        if contact.unread_badge_date_time != "" && formattedTodayDate >= contact.unread_badge_date_time {
            return true
        } else {
            return false
        }
    }
}

#Preview {
    ContactRowView(contact: SelectedContact.sampleData)
}
