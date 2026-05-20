//
//  UpdatesScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/29/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct UpdatesScreen: View {
    private let currentVersionNotes: [String] = [
        "Support for iOS 26 and Liquid Glass",
        "Enable contact list searching",
        "Various bug fixes and performance improvements"
    ]

    private let version3Notes: [String] = [
        "A grid of your next CatchUps",
        "Pull-to-refresh photo & contact information for your selected contacts",
        "Unread indicators for contacts it's time to CatchUp with",
        "Automatic cloud syncing with other Apple devices",
        "UI redesign",
        "Significant under-the-hood improvements"
    ]

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                UpdatesScreenHeader()

                ReleaseNotesSection(notes: currentVersionNotes)

                Text("***From version 3.0***:")
                    .padding(.top)

                ReleaseNotesSection(notes: version3Notes)

                Button(action: Utils.requestReviewManually) {
                    CalloutButtonView(buttonText: "Review on the App Store", buttonColor: .orange)
                }
                .padding(.vertical)
            }
        }
        .padding([.top, .horizontal])
    }
}

#Preview {
    UpdatesScreen()
}
