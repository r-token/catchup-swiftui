//
//  PhoneInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct PhoneInfoRow: View {
    @Environment(\.openURL) private var openURL

    let title: LocalizedStringKey
    let formattedNumber: String
    let tappableNumber: URL?
    @Binding var isShowingInvalidPhoneAlert: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)

            Button(formattedNumber, action: tapAction)
                .foregroundStyle(.blue)
        }
    }

    private func tapAction() {
        if let tappableNumber {
            openURL(tappableNumber)
        } else {
            isShowingInvalidPhoneAlert = true
        }
    }
}

#Preview {
    PhoneInfoRow(
        title: "Phone",
        formattedNumber: "+1 (636) 368-7771",
        tappableNumber: URL(string: "tel://+16363687771"),
        isShowingInvalidPhoneAlert: .constant(false)
    )
}
