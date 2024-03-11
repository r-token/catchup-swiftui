//
//  OpenContactPickerButtonView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct OpenContactPickerButtonView: View {
    var body: some View {
        HStack(alignment: .center, spacing: 6) {
            Image(systemName: "person.crop.circle.fill.badge.plus")

            Text("Add Contacts")
        }
        .font(.headline)
        .foregroundColor(.blue)
        .padding(.top)
        .padding(.bottom)
    }
}

#Preview {
    OpenContactPickerButtonView()
}
