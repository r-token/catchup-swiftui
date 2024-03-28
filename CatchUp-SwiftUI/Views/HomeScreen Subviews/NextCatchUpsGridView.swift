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

    var nextCatchUps: [SelectedContact]
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
                        Text(contact.name.components(separatedBy: " ").first ?? contact.name)
                            .font(.headline)

                        Text(friendlyNextCatchUpTime(for: contact))
                            .foregroundStyle(.gray)
                            .font(.caption)
                    }
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(10)
                .background(colorScheme == .light ? Color.white : Color(UIColor(red: 0.15, green: 0.15, blue: 0.15, alpha: 1)))
                .cornerRadius(10)
                .if(colorScheme == .light) { view in
                    view.shadow(color: Color.gray.opacity(0.4), radius: 3, x: 0, y: 2)
                }

                .onTapGesture {
                    tappedGridContact = contact
                    shouldNavigateViaGrid = true
                }
            }
        }
        .padding(.bottom, 5)
        .listRowInsets(EdgeInsets(top: 5, leading: 0, bottom: 0, trailing: 0))
        .listRowBackground(Color.clear)
    }

    func friendlyNextCatchUpTime(for contact: SelectedContact) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: contact.next_notification_date_time) {
            let friendlyFormatter = DateFormatter()

            if Calendar.current.isDateInToday(date) {
                friendlyFormatter.dateFormat = "h:mm a"
                return "Today at \(friendlyFormatter.string(from: date))"
            } else if Calendar.current.isDateInTomorrow(date) {
                friendlyFormatter.dateFormat = "h:mm a"
                return "Tomorrow at \(friendlyFormatter.string(from: date))"
            } else {
                friendlyFormatter.dateFormat = "MMMM d 'at' h:mm a"
                return friendlyFormatter.string(from: date)
            }
        } else {
            return "Unknown"
        }
    }
}

#Preview {
    NextCatchUpsGridView(
        nextCatchUps: [SelectedContact.sampleData, SelectedContact.sampleData, SelectedContact.sampleData],
        shouldNavigateViaGrid: .constant(false),
        tappedGridContact: .constant(SelectedContact.sampleData)
    )
}
