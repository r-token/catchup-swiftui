//
//  WeekdayPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct WeekdayPicker: View {
    @Binding var selection: Int
    let label: String
    let options: [DayOption]

    var body: some View {
        Picker(selection: $selection) {
            ForEach(options.indices, id: \.self) { index in
                Text(options[index].rawValue)
                    .tag(index + 1)
            }
        } label: {
            Text(label)
        }
    }
}

#Preview {
    WeekdayPicker(selection: .constant(1), label: "What day?", options: DayOption.allCases)
}
