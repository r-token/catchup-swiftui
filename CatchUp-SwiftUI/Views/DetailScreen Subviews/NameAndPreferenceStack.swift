//
//  NameAndPreferenceStack.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NameAndPreferenceStack: View {
    let contact: SelectedContact

    var body: some View {
        VStack(alignment: .center, spacing: 10) {
            Text(contact.name)
                .font(.largeTitle)
                .bold()

            Text("Preference: \(Converter.convertNotificationPreferenceToString(contact: contact))")
                .foregroundStyle(.secondary)
        }
        .padding(.bottom, 5)
    }
}

#Preview {
    NameAndPreferenceStack(contact: .sampleData)
}
