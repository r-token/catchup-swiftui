//
//  MonthPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct MonthPicker: View {
    @Binding var selection: Int
    let options: [MonthOption]

    var body: some View {
        Picker("What month?", selection: $selection) {
            ForEach(options.indices, id: \.self) { index in
                Text(options[index].rawValue)
                    .tag(index + 1)
            }
        }
    }
}

#Preview {
    MonthPicker(selection: .constant(1), options: MonthOption.allCases)
}
