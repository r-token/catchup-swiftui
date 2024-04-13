//
//  NextCatchUpRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/29/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NextCatchUpRow: View {
    let nextCatchUpTime: String

    var body: some View {
        HStack(spacing: 0) {
            Text("Next CatchUp:")

            Spacer()

            Text(nextCatchUpTime)
                .foregroundStyle(.gray)
        }
        .listRowSeparator(.hidden)
    }
}

#Preview {
    NextCatchUpRow(nextCatchUpTime: "December 29 at 7:15 AM")
}
