//
//  Conversions.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/12/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation

struct Conversions {
	
	func convertNotificationPreferenceIntToString(preference: Int) -> String {
		switch preference {
		case 0:
			return "No Reminder Set"
		case 1:
			return "Daily"
		case 2:
			return "Weekly"
		case 3:
			return "Monthly"
		case 4:
			return "Custom"
		default:
			return "Unknown"
		}
	}
	
}
