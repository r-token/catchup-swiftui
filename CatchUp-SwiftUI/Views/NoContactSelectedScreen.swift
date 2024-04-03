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
        HStack {
            Spacer()

            VStack {
                Spacer()

                Image("CatchUp")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .shadow(radius: 15)
                    .padding(.bottom)

                Text("Select a contact from the left sidebar to get started.")
                    .fontWeight(.semibold)

                Spacer()
                Spacer()
            }

            Spacer()
        }
    }
}

#Preview {
    NoContactSelectedScreen()
}
