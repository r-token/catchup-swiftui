//
//  PreferenceScreen.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import UserNotifications

struct PreferenceScreen: View {
	@State private var notificationChoice = 0
	@State private var dayChoice = 0
	@State private var notificationTime = Date()
	@Environment(\.managedObjectContext) var managedObjectContext
	
	let now = Date()
    var notificationOptions = ["Never", "Daily", "Weekly", "Monthly", "Custom"]
	var dayOptions = ["Mon", "Tues", "Wed", "Thur", "Fri", "Sat", "Sun"]
	var contact: SelectedContact

    var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Text("Preference")
				.font(.largeTitle)
				.bold()
				.foregroundColor(.orange)
				.padding(.top)
				.padding(5)
			
			Text("How often should we notify you to CatchUp with \(contact.name)?")
				.padding(5)
			
			Picker(selection: $notificationChoice, label: Text("How often should we notify you to CatchUp with \(contact.name)?")) {
                ForEach(0..<notificationOptions.count) { index in
                    Text(self.notificationOptions[index]).tag(index)
                }
            }.pickerStyle(SegmentedPickerStyle())
				
			.padding(.top)
			
			VStack(alignment: .leading, spacing: 20) {
				
				if notificationChoice != 0 && notificationChoice != 4 { // Daily, Weekly, or Monthly
					Text("What time?")
						.padding(.top)
					DatePicker("What time should we notify you?", selection: $notificationTime, displayedComponents: .hourAndMinute)
						.labelsHidden()
					
					if notificationChoice == 2 { // Weekly
						Text("What day?")
					}
					if notificationChoice == 3 { // Monthly
						Text("What day? We'll pick a random week of the month.")
					}
					
					if notificationChoice == 2 || notificationChoice == 3 {
						Picker(selection: $dayChoice, label: Text("Which day of the week?")) {
							ForEach(0..<dayOptions.count) { index in
								Text(self.dayOptions[index]).tag(index)
							}
						}.pickerStyle(SegmentedPickerStyle())
					}
				}
				
				if notificationChoice == 4 { // Yearly
					VStack(alignment: .leading, spacing: 20) {
						Text("When would you like to be notified?")
							.padding(.top)
						DatePicker("What day and time should we notify you?", selection: $notificationTime, in: Date()..., displayedComponents: .date)
							.labelsHidden()
					}
				}
			}
			
			Spacer()
        }
		.padding(8)
    }
}

