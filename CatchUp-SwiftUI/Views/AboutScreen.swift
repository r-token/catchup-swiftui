//
//  AboutScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/19/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct AboutScreen: View {
    @State private var isShowingUpdateScreen = false

    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 15) {
                Spacer()
                    .frame(height: 75)

                AboutScreenHeader()

                OrangeDivider()
                    .padding(.bottom)

                TipJarSection()

                OrangeDivider()

                Button(action: Utils.requestReviewManually) {
                    CalloutButtonView(buttonText: "Review on the App Store", buttonColor: .orange)
                }
                .padding(.vertical)

                Button("Show Latest Update Details") {
                    isShowingUpdateScreen = true
                }
                .font(.headline)
                .foregroundStyle(.blue)
                .padding(.bottom)
            }
        }
        .padding(.horizontal)
        .sheet(isPresented: $isShowingUpdateScreen) {
            UpdatesScreen()
        }
    }
}

#Preview {
    AboutScreen()
}
