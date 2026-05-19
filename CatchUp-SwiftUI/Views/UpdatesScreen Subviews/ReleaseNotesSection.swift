//
//  ReleaseNotesSection.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import SwiftUI

struct ReleaseNotesSection: View {
    let notes: [String]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(notes, id: \.self) { note in
                Text("– \(note)")
            }
        }
    }
}

#Preview {
    ReleaseNotesSection(notes: [
        "Sample note 1",
        "Sample note 2 with more text to wrap to a second line."
    ])
}
