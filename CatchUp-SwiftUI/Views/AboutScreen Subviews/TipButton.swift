//
//  TipButton.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct TipButton: View {
    let amount: String
    let action: () -> Void

    var body: some View {
        Button(amount, action: action)
            .font(.headline)
            .foregroundStyle(.white)
            .padding()
            .background(tipGradient, in: .rect(cornerRadius: 20))
            .shadow(radius: 15)
            .frame(maxWidth: .infinity)
    }

    private var tipGradient: LinearGradient {
        LinearGradient(
            colors: [.orange, .red],
            startPoint: .top,
            endPoint: .bottom
        )
    }
}

#Preview {
    HStack {
        TipButton(amount: "$1", action: {})
        TipButton(amount: "$3", action: {})
        TipButton(amount: "$5", action: {})
    }
    .padding()
}
