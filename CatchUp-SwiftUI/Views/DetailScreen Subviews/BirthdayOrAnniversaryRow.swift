//
//  BirthdayOrAnniversaryRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/31/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct BirthdayOrAnniversaryRow: View {
    let contact: SelectedContact

    var body: some View {
        if !contact.birthday.isEmpty, contact.next_notification_date_time.contains(contact.birthday) {
            HStack {
                Spacer()
                Text("🥳 \(ContactHelper.getFirstName(for: contact))'s birthday!")
                    .foregroundStyle(.orange)
                Spacer()
            }
            .padding(.top, 2)
        } else if let anniversaryString = dayBeforeAnniversaryString(),
                  contact.next_notification_date_time == anniversaryString {
            Text("💜 The day before their anniversary!")
                .foregroundStyle(.purple)
                .multilineTextAlignment(.leading)
                .padding(.top, 2)
        }
    }

    private func dayBeforeAnniversaryString() -> String? {
        guard contact.hasAnniversary() else { return nil }
        return NotificationHelper.calculateDateStringFromComponents(
            NotificationHelper.getAnniversaryDateComponents(for: contact)
        )
    }
}

#Preview {
    BirthdayOrAnniversaryRow(contact: .sampleData)
}
