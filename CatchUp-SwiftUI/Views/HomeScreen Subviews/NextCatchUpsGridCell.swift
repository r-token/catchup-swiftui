//
//  NextCatchUpsGridCell.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct NextCatchUpsGridCell: View {
    @Environment(\.colorScheme) private var colorScheme

    let contact: SelectedContact
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                ContactPictureView(contact: contact)
                    .padding(.trailing, 5)

                VStack(alignment: .leading, spacing: 2) {
                    Text(ContactHelper.getFirstName(for: contact))
                        .font(.headline)

                    Text(ContactHelper.getFriendlyNextCatchUpTime(for: contact, forQuarterlyPreference: false))
                        .foregroundStyle(.secondary)
                        .font(.caption)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: 55, maxHeight: 65)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(cellBackground)
            .clipShape(.capsule)
            .shadow(
                color: colorScheme == .light ? Color.gray.opacity(0.4) : .clear,
                radius: 3,
                x: 0,
                y: 2
            )
        }
        .buttonStyle(.plain)
    }

    private var cellBackground: Color {
        colorScheme == .light ? .white : Color(red: 0.15, green: 0.15, blue: 0.15)
    }
}

#Preview {
    NextCatchUpsGridCell(contact: .sampleData, action: {})
}
