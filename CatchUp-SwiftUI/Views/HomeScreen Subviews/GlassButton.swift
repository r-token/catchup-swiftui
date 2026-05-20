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
    @ViewBuilder let label: Label

    var body: some View {
        Button(action: action) { label }
            .buttonStyle(.glass)
    }
}

#Preview {
    GlassButton(action: {}) {
        OpenContactPickerButtonView()
    }
    .padding()
}
