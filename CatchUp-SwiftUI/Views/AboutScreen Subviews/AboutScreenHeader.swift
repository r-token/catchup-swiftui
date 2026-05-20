//
//  AboutScreenHeader.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct AboutScreenHeader: View {
    var body: some View {
        VStack(spacing: 15) {
            Image("CatchUp")
                .resizable()
                .frame(width: 80, height: 80)
                .clipShape(.rect(cornerRadius: 15))
                .shadow(radius: 10)
                .accessibilityHidden(true)

            Text("CatchUp")
                .foregroundStyle(.orange)
                .font(.largeTitle)
                .bold()

            Text("Made with ❤️ by an independent developer")
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom)
        }
    }
}

#Preview {
    AboutScreenHeader()
}
