//
//  ContactRowView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactRowView: View {
    let contact: SelectedContact

    var body: some View {
        HStack {
            Converter.getContactPicture(from: contact.picture)
                .renderingMode(.original)
                .resizable()
                .frame(width: 45, height: 45, alignment: .leading)
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 2) {
                Text(contact.name)
                    .font(.headline)
                Text(Converter.convertNotificationPreferenceIntToString(preference: Int(contact.notification_preference), contact: contact))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ContactRowView(contact: SelectedContact.sampleData)
}
