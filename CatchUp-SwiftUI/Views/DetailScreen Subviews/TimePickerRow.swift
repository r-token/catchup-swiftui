//
//  TimePickerRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/7/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct TimePickerRow: View {
    @Binding var notificationPreferenceTime: Date

    var body: some View {
        HStack {
            Text("What time?")

            Spacer()

            DatePicker("What time?", selection: $notificationPreferenceTime, displayedComponents: .hourAndMinute)
                .labelsHidden()
        }
    }
}

#Preview {
    TimePickerRow(notificationPreferenceTime: .constant(Date()))
}
