//
//  GlassButton.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 9/24/25.
//  Copyright © 2025 Token Solutions. All rights reserved.
//

import SwiftUI

struct GlassButton<Label: View>: View {
    let action: () -> Void
    @ViewBuilder let label: () -> Label

    init(action: @escaping () -> Void, @ViewBuilder label: @escaping () -> Label) {
        self.action = action
        self.label = label
    }

    var body: some View {
        if #available(iOS 26, macOS 26, *) {
            Button(action: action, label: label)
                .buttonStyle(.glass)
        } else {
            Button(action: action, label: label)
                .buttonStyle(.bordered)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.bottom)
        }
    }
}

#Preview {
    GlassButton(action: {}) {
        OpenContactPickerButtonView()
    }
    .padding()
}
