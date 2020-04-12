//
//  Gradient.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct GradientView: View {
    var body: some View {
		let colors = Gradient(colors: [.blue, .white])
		let conic = RadialGradient(gradient: colors, center: .center, startRadius: 50, endRadius: 200)
		
		return Rectangle()
			.fill(conic)
	}
}

struct Gradient_Previews: PreviewProvider {
    static var previews: some View {
        GradientView()
    }
}
