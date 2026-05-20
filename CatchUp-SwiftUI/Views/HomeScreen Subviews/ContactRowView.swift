//
//  ContactRowView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactRowView: View {
    @Environment(DataController.self) private var dataController
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

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
                    .foregroundStyle(subtitleStyle)
            }

            Spacer()

            if shouldShowUnreadIndicator {
                Circle()
                    .foregroundStyle(.orange)
                    .frame(width: 15, height: 15)
                    .padding(.horizontal)
                    .accessibilityLabel("Unread")
            }
        }
        .onAppear {
            shouldShowUnreadIndicator = determineIfShouldShowIndicator()
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                shouldShowUnreadIndicator = determineIfShouldShowIndicator()
            }
        }
        .onChange(of: dataController.selectedContact) {
            shouldShowUnreadIndicator = determineIfShouldShowIndicator()
        }
    }

    private var isHighlightedOnRegularWidth: Bool {
        horizontalSizeClass == .regular && dataController.selectedContact == contact
    }

    private var subtitleStyle: AnyShapeStyle {
        isHighlightedOnRegularWidth ? AnyShapeStyle(.white) : AnyShapeStyle(.secondary)
    }

    private func determineIfShouldShowIndicator() -> Bool {
        guard !contact.unread_badge_date_time.isEmpty else { return false }
        let formattedTodayDate = Self.storedDateFormatter.string(from: .now)
        return formattedTodayDate >= contact.unread_badge_date_time
    }

    private static let storedDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter
    }()
}

#Preview {
    ContactRowView(contact: .sampleData)
        .environment(DataController())
}
