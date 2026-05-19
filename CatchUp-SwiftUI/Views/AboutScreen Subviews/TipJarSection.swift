//
//  TipJarSection.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct TipJarSection: View {
    private let smallTip = IAPService.shared.getSmallTipAmount()
    private let mediumTip = IAPService.shared.getMediumTipAmount()
    private let largeTip = IAPService.shared.getLargeTipAmount()

    @State private var tipTrigger = 0

    var body: some View {
        VStack(spacing: 15) {
            Text("Tip Jar")
                .font(.headline)

            Text("CatchUp is free with no ads. If you find it useful, please consider supporting development by leaving a tip or review.")
                .multilineTextAlignment(.center)
                .padding(.bottom)

            HStack {
                TipButton(amount: smallTip, action: { leaveTip(at: 0) })
                TipButton(amount: mediumTip, action: { leaveTip(at: 1) })
                TipButton(amount: largeTip, action: { leaveTip(at: 2) })
            }
            .padding(.bottom, 20)
        }
        .sensoryFeedback(.success, trigger: tipTrigger)
    }

    private func leaveTip(at index: Int) {
        tipTrigger &+= 1
        IAPService.shared.leaveATip(index: index)
    }
}

#Preview {
    TipJarSection()
}
