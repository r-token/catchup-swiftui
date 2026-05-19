//
//  Gradient.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct GradientView: View {
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Rectangle()
            .fill(RadialGradient(
                gradient: Gradient(colors: [.blue, isLight ? .white : .black]),
                center: .bottom,
                startRadius: isLight ? 80 : 40,
                endRadius: 190
            ))
    }

    private var isLight: Bool { colorScheme == .light }
}

#Preview {
    VStack {
        GradientView()
            .ignoresSafeArea(edges: .top)
            .frame(height: 150)
        Spacer()
    }
}
