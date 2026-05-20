//
//  CustomDatePicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct CustomDatePicker: View {
    @Binding var selection: Date

    var body: some View {
        LabeledContent("When would you like to be notified?") {
            DatePicker(
                "When would you like to be notified?",
                selection: $selection,
                in: Date.now...,
                displayedComponents: .date
            )
            .labelsHidden()
        }
    }
}

#Preview {
    CustomDatePicker(selection: .constant(.now))
}
