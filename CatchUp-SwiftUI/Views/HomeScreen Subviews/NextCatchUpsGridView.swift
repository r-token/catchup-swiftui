//
//  NextCatchUpsGridView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/24/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NextCatchUpsGridView: View {
    @Environment(\.colorScheme) var colorScheme

    let nextCatchUps: [SelectedContact]
    @Binding var shouldNavigateViaGrid: Bool
    @Binding var tappedGridContact: SelectedContact?

    // 2 column grid
    let columns = [
        GridItem(.flexible(minimum: 0, maximum: .infinity)),
        GridItem(.flexible(minimum: 0, maximum: .infinity))
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(nextCatchUps) { contact in
                HStack {
                    ContactPictureView(contact: contact)
                        .padding(.trailing, 5)

                    VStack(alignment: .leading, spacing: 2) {
                        Text(ContactHelper.getFirstName(for: contact))
                            .font(.headline)

                        Text(ContactHelper.getFriendlyNextCatchUpTime(for: contact, forQuarterlyPreference: false))
                            .foregroundStyle(.gray)
                            .font(.caption)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .frame(minHeight: 55, maxHeight: 65)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(colorScheme == .light ? Color.white : Color(UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)))
                .clipShape(Capsule())
                .if(colorScheme == .light) {
                    $0.shadow(color: Color.gray.opacity(0.4), radius: 3, x: 0, y: 2)
                }

                .onTapGesture {
                    tappedGridContact = contact
                    shouldNavigateViaGrid = true
                }
            }
        }
        .padding(.bottom, 5)
        .padding(.horizontal, 4)
        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }
}

#Preview {
    NextCatchUpsGridView(
        nextCatchUps: [SelectedContact.sampleData, SelectedContact.sampleData, SelectedContact.sampleData],
        shouldNavigateViaGrid: .constant(false),
        tappedGridContact: .constant(SelectedContact.sampleData)
    )
}
