//
//  Gradient.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct GradientView: View {
	@Environment(\.colorScheme) var colorScheme
	
    var body: some View {
		if colorScheme == .light {
			let colors = Gradient(colors: [.blue, .white])
			let conic = RadialGradient(gradient: colors, center: .bottom, startRadius: 80, endRadius: 190)
			
			return Rectangle()
				.fill(conic)
			
		} else { // colorScheme == .dark
			let colors = Gradient(colors: [.blue, .black])
			let conic = RadialGradient(gradient: colors, center: .bottom, startRadius: 40, endRadius: 190)
			
			return Rectangle()
				.fill(conic)
		}
	}
}

#Preview {
    VStack {
        GradientView()
            .edgesIgnoringSafeArea(.top)
            .frame(height: 150)
        Spacer()
    }
}
