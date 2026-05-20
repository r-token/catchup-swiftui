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
        Text(buttonText)
            .bold()
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .foregroundStyle(.white)
            .background(buttonColor, in: .rect(cornerRadius: 20))
    }
}

#Preview {
    CalloutButtonView(buttonText: "Remove Bee", buttonColor: .red)
}
