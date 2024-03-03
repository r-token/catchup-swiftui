//
//  CatchUpApp.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/3/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

@main
struct CatchUpApp: App {
    var body: some Scene {
        WindowGroup {
            HomeScreen()
        }
        .modelContainer(for: SelectedContact.self)
    }
}
