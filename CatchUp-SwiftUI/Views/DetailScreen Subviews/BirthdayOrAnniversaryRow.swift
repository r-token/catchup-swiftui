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
        if contact.next_notification_date_time.contains(contact.birthday) {
            VStack {
                HStack {
                    Spacer()
                    Text("🥳 \(ContactHelper.getFirstName(for: contact))'s birthday!")
                        .foregroundStyle(.orange)
                    Spacer()
                }
                .padding(.top, 2)

                Spacer()
            }
        } else if contact.next_notification_date_time == dayBeforeAnniversaryString() {
            VStack {
                HStack {
                    Spacer()
                    Text("🧡 The day before your anniversary!")
                        .foregroundStyle(.orange)
                    Spacer()
                }
                .padding(.top, 2)

                Spacer()
            }
        }
    }

    func dayBeforeAnniversaryString() -> String {
        if ContactHelper.contactHasAnniversary(contact) {
            return NotificationHelper.calculateDateFromComponents(NotificationHelper.getAnniversaryDateComponents(for: contact))
        }

        return ""
    }
}

#Preview {
    BirthdayOrAnniversaryRow(contact: SelectedContact.sampleData)
}
