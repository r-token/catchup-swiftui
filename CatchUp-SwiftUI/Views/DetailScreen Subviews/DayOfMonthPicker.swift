//
//  DayOfMonthPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct DayOfMonthPicker: View {
    @Binding var selection: Int

    var body: some View {
        Picker("What day?", selection: $selection) {
            ForEach(1...28, id: \.self) { day in
                Text("\(day)")
                    .tag(day)
            }
        }
    }
}

#Preview {
    DayOfMonthPicker(selection: .constant(1))
}
