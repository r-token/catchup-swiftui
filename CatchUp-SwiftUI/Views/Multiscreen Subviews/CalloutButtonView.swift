//
//  CalloutButtonView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/12/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct CalloutButtonView: View {
    let buttonText: String
    let buttonColor: Color

    var body: some View {
        HStack {
            Spacer()

            Text(buttonText)

            Spacer()
        }
        .fontWeight(.semibold)
        .padding(.vertical, 12)
        .foregroundStyle(.white)
        .background(
            RoundedRectangle(
                cornerRadius: 20,
                style: .continuous
            )
            .fill(buttonColor)
        )
    }
}

#Preview {
    CalloutButtonView(buttonText: "Remove Bee", buttonColor: .red)
}
