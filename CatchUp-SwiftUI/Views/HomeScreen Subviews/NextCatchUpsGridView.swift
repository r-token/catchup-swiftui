//
//  NextCatchUpsGridView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/24/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NextCatchUpsGridView: View {
    let nextCatchUps: [SelectedContact]
    @Binding var tappedGridContact: SelectedContact?

    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(nextCatchUps) { contact in
                NextCatchUpsGridCell(contact: contact) {
                    tappedGridContact = contact
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
        nextCatchUps: [.sampleData, .sampleData, .sampleData],
        tappedGridContact: .constant(nil)
    )
}
