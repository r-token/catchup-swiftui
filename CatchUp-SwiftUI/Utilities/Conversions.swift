//
//  Conversions.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/12/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation
import SwiftUI
import PhoneNumberKit

class Converter {
    // MARK: Only used in DetailScreen
    static func getFormattedPhoneNumber(from phoneNumber: String) -> String {
        let phoneNumberKit = PhoneNumberKit()

        print("formatting phone number: \(phoneNumber)")

        do {
            let parsedPhoneNumber = try phoneNumberKit.parse(phoneNumber.trimmingCharacters(in: .whitespacesAndNewlines))
            let formattedPhoneNumber = phoneNumberKit.format(parsedPhoneNumber, toType: .national)
            return formattedPhoneNumber
        }
        catch {
            print("PhoneNumberKit Parse Error: \(error)")
            return phoneNumber
        }
    }
    
    static func getTappablePhoneNumber(from phoneNumber: String) -> URL {
        print("getting tappable phone number: \(phoneNumber)")

        let tel = "tel://"
        let cleanNumber = phoneNumber.replacingOccurrences(of: "[^\\d+]", with: "", options: [.regularExpression])
        let formattedString = tel + cleanNumber
        let tappableNumber = URL(string: formattedString)!
        
        return tappableNumber
    }
    
    static func getTappableEmail(from emailAddress: String) -> URL {
        let mailto = "mailto:"
        let formattedString = mailto + emailAddress
        let tappableEmail = URL(string: formattedString)!
        
        return tappableEmail
    }
    
    static func getFormattedBirthdayOrAnniversary(from storedDate: String) -> String {
        var month = storedDate.prefix(2)
        let day = storedDate.suffix(2)
        
        switch month {
        case "01":
            month = "January"
            break
        case "02":
            month = "February"
            break
        case "03":
            month = "March"
            break
        case "04":
            month = "April"
            break
        case "05":
            month = "May"
            break
        case "06":
            month = "June"
            break
        case "07":
            month = "July"
            break
        case "08":
            month = "August"
            break
        case "09":
            month = "September"
            break
        case "10":
            month = "October"
            break
        case "11":
            month = "November"
            break
        case "12":
            month = "December"
            break
        default:
            break
        }
        
        let formattedDate = month + " " + day
        return String(formattedDate)
    }
    
    
    // MARK: Used in HomeScreen and DetailScreen
    
    static func getContactPicture(from string: String) -> Image {
        let imageData = NSData(base64Encoded: string)
        let uiImage = UIImage(data: imageData! as Data)!
        let image = Image(uiImage: uiImage)
        
        return image
    }
	
    static func convertNotificationPreferenceIntToString(preference: Int, contact: SelectedContact) -> String {
		let time = convertHourAndMinuteFromIntToString(for: contact)
		let weekday = convertWeekdayFromIntToString(for: contact)
		let customDate = convertCustomDateFromIntToString(for: contact)
		
		switch preference {
		case 0:
			return "No Reminder Set"
		case 1:
			return "Daily at \(time)"
		case 2:
			return "\(weekday)s at \(time)"
		case 3:
			return "Monthly on \(weekday)s"
		case 4:
			return customDate
		default:
			return "Unknown"
		}
	}
	
    static func convertWeekdayFromIntToString(for contact: SelectedContact) -> String {
		let weekday: String
		
		switch contact.notification_preference_weekday {
		case 0:
			weekday = "Sunday"
			break
		case 1:
			weekday = "Monday"
			break
		case 2:
			weekday = "Tuesday"
			break
		case 3:
			weekday = "Wednesday"
			break
		case 4:
			weekday = "Thursday"
			break
		case 5:
			weekday = "Friday"
			break
		case 6:
			weekday = "Saturday"
			break
		default:
			weekday = "Unknown"
			break
		}
		
		return weekday
	}
	
    static func convertHourAndMinuteFromIntToString(for contact: SelectedContact) -> String {
		var hour: String
		var suffix: String
		
		let am = "am"
		let pm = "pm"
		
		switch contact.notification_preference_hour {
		case 0:
			hour = "12:"
			suffix = am
			break
		case 1:
			hour = "1:"
			suffix = am
			break
		case 2:
			hour = "2:"
			suffix = am
			break
		case 3:
			hour = "3:"
			suffix = am
			break
		case 4:
			hour = "4:"
			suffix = am
			break
		case 5:
			hour = "5:"
			suffix = am
			break
		case 6:
			hour = "6:"
			suffix = am
			break
		case 7:
			hour = "7:"
			suffix = am
			break
		case 8:
			hour = "8:"
			suffix = am
			break
		case 9:
			hour = "9:"
			suffix = am
			break
		case 10:
			hour = "10:"
			suffix = am
		case 11:
			hour = "11:"
			suffix = am
		case 12:
			hour = "12:"
			suffix = pm
		case 13:
			hour = "1:"
			suffix = pm
		case 14:
			hour = "2:"
			suffix = pm
		case 15:
			hour = "3:"
			suffix = pm
		case 16:
			hour = "4:"
			suffix = pm
		case 17:
			hour = "5:"
			suffix = pm
		case 18:
			hour = "6:"
			suffix = pm
		case 19:
			hour = "7:"
			suffix = pm
		case 20:
			hour = "8:"
			suffix = pm
		case 21:
			hour = "9:"
			suffix = pm
		case 22:
			hour = "10:"
			suffix = pm
		case 23:
			hour = "11:"
			suffix = pm
		default:
			hour = "Unknown"
			suffix = ""
		}
		
		var minute = String(contact.notification_preference_minute)
		if minute.count == 1 {
			minute = "0" + minute
		}
		let time = (hour+minute+suffix)
		
		return time
	}
	
    static func convertCustomDateFromIntToString(for contact: SelectedContact) -> String {
		var month: String
		var day: String
		var year: String
		
		switch contact.notification_preference_custom_month {
		case 1:
			month = "January"
			break
		case 2:
			month = "February"
			break
		case 3:
			month = "March"
			break
		case 4:
			month = "April"
			break
		case 5:
			month = "May"
			break
		case 6:
			month = "June"
			break
		case 7:
			month = "July"
			break
		case 8:
			month = "August"
			break
		case 9:
			month = "September"
			break
		case 10:
			month = "October"
			break
		case 11:
			month = "November"
			break
		case 12:
			month = "December"
			break
		default:
			month = "Unknown"
			break
		}
		
		let formatter = DateFormatter()
		formatter.dateFormat = "dd"
		
		var dateComponents = DateComponents()
		dateComponents.month = Int(contact.notification_preference_custom_month)
		dateComponents.day = Int(contact.notification_preference_custom_day)
		dateComponents.year = Int(contact.notification_preference_custom_year)
		
		let dateTime = Calendar.current.date(from: dateComponents)
		let dateString = formatter.string(from: dateTime!)
		let dayDate = formatter.date(from: dateString)!
		
		day = formatter.string(from: dayDate)
		year = String(contact.notification_preference_custom_year)
		
		let customDate = ("\(month) \(day), \(year)")
		
		return customDate
	}
}
