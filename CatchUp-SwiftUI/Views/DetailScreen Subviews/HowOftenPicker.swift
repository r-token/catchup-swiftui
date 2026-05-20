//
//  HowOftenPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct HowOftenPicker: View {
    @Binding var selection: Int
    let options: [NotificationOption]

    var body: some View {
        Picker("How often?", selection: $selection) {
            ForEach(options.indices, id: \.self) { index in
                Text(options[index].rawValue)
                    .tag(index)
            }
        }
    }
}

#Preview {
    HowOftenPicker(selection: .constant(0), options: NotificationOption.allCases)
}
