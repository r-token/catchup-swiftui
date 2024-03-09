//
//  ContactPhoto.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactPhoto: View {
    var image: Image

    var body: some View {
        image
			.resizable()
			.frame(width: 150, height: 150)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
    }
}

#Preview {
    ContactPhoto(image: Image("DefaultPhoto"))
}
