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
        Label("Add Contacts", systemImage: "person.crop.circle.fill.badge.plus")
            .font(.headline)
            .foregroundStyle(.blue)
            .padding(10)
    }
}

#Preview {
    OpenContactPickerButtonView()
}
