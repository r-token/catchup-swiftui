//
//  EmailInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct EmailInfoRow: View {
    let title: LocalizedStringKey
    let email: String
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)

            Button(email, action: action)
                .foregroundStyle(.blue)
        }
    }
}

#Preview {
    EmailInfoRow(title: "Email", email: "test@example.com", action: {})
}
