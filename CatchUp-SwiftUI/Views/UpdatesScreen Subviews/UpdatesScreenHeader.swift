//
//  UpdatesScreenHeader.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct UpdatesScreenHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Spacer()
                .frame(height: 10)

            Text("New Update")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.orange)

            Text("Version \(Utils.getCurrentAppVersion())")
                .font(.headline)
                .foregroundStyle(.blue)

            Text("Release Notes:")
                .font(.headline)

            Divider()
        }
    }
}

#Preview {
    UpdatesScreenHeader()
}
