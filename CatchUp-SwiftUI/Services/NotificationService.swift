//
//  NotificationService.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/21/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import UserNotifications

struct NotificationService {
	
    static func setBadgeIndicator(badgeCount: Int) {
	  let application = UIApplication.shared
	  if #available(iOS 10.0, *) {
		let center = UNUserNotificationCenter.current()
		center.requestAuthorization(options: [.badge, .alert, .sound]) { _, _ in }
	  } else {
		application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil))
	  }
	  application.registerForRemoteNotifications()
	  application.applicationIconBadgeNumber = badgeCount
	}
	
	func generateRandomNotificationSubtitle() -> String {
		let randomInt = Int.random(in: 0..<19)
		
		switch randomInt {
			case 0:
				return "Now you can be best buddies again"
			case 1:
				return "A little birdy told me they really miss you"
			case 2:
				return "It's time to check back in"
			case 3:
				return "You're a good friend. Go you. Tell this person to get CatchUp too so it's not always you who's reaching out"
			case 4:
				return "Today is the perfect day to get back in touch"
			case 5:
				return "Remember to keep in touch with the people that matter most"
			case 6:
				return "You know what they say: 'A CatchUp message a day keeps the needy friends at bay'"
			case 7:
				return "Have you written a physical letter in a while? Maybe give that a try this time? People like that"
			case 8:
				return "Here's that reminder you set to check in with someone important. Maybe you'll make their day"
			case 9:
				return "Once a good person, always a good person (you are a good person, and probably so is the person you want to be reminded to CatchUp with)"
			case 10:
				return "Here's another reminder to get back in touch with ⬆️"
			case 11:
				return "Time to get back in contact with one of your favorite people"
			case 12:
				return "So nice of you to want to stay in touch with the people you care about"
			case 13:
				return "You know they'll really appreciate it"
			case 14:
				return "I'm not guilting you into this or anything, but this person will probably be subconsciously sad if you don't say hello."
			case 15:
				return "You have this app, so you're cool and nice. Now send a thoughtful message to this also cool and nice person"
			case 16:
				return "Once upon a time, there was a nice person. The end. (Spoiler: you're the nice person - keep being nice and reach out to this person)"
			case 17:
				return "Another timely reminder to catch up. Just the way you wanted it"
			case 18:
				return "Now is the time! Seize the moment!"
			case 19:
				return "Good job keeping your friends close. Now keep your enemies closer 😉"
			default:
				return "Keep in touch"
        }
	}
    
    func requestAuthorizationForNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("User authorized CatchUp to send notifications")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
