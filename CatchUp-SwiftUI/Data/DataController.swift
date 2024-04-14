//
//  DataController.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/31/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import Foundation
import SwiftData

@Observable
class DataController {
    var selectedContact: SelectedContact?

    @MainActor
    static let previewContainer: ModelContainer = {
        do {
            let config = ModelConfiguration(isStoredInMemoryOnly: true)
            let container = try ModelContainer(for: SelectedContact.self, configurations: config)

            for i in 1...9 {
                let contact = SelectedContact.sampleData
                container.mainContext.insert(contact)
            }

            return container
        } catch {
            fatalError("Failed to create model container for previewing: \(error.localizedDescription)")
        }
    }()
}
