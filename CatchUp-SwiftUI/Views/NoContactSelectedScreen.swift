//
//  NoContactSelectedScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/1/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct NoContactSelectedScreen: View {
    var body: some View {
        VStack {
            Image("CatchUp")
                .resizable()
                .frame(width: 100, height: 100)
                .clipShape(.rect(cornerRadius: 20))
                .shadow(radius: 15)
                .padding(.bottom)
                .accessibilityHidden(true)

            Text("Select a contact from the left sidebar to get started.")
                .bold()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NoContactSelectedScreen()
}
