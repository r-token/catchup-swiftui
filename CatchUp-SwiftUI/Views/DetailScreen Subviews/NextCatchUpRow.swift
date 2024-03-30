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
        HStack {
            Text("Next CatchUp:")

            Spacer()

            Text(nextCatchUpTime)
                .foregroundStyle(.gray)
        }
    }
}

#Preview {
    NextCatchUpRow()
}
