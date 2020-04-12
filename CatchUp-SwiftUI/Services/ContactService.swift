//
//  ContactUtilityFunctions.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import UIKit
import Contacts

class ContactService {
	func getContactPicture(for contact: CNContact) -> String {
		let picture: String
		
		if contact.imageDataAvailable == true {
			picture = (contact.thumbnailImageData?.base64EncodedString())!
		} else {
			// there is not an image for this contact, use the default image
			let image = UIImage(named: "DefaultPhoto")
			let imageData: NSData = image!.pngData()! as NSData
			picture = imageData.base64EncodedString()
		}
		
		print(picture)
		return picture
	}

	func getContactName(for contact: CNContact) -> String {
		var name:String
		
		//if they have a first and a last name
		if contact.givenName != "" && contact.familyName != "" {
			name = contact.givenName + " " + contact.familyName
			//if they have a first name, but no last name
		} else if contact.givenName != "" && contact.familyName == "" {
			name = contact.givenName
			//if they have no first name, but have a last name
		} else if contact.givenName == "" && contact.familyName != "" {
			name = contact.familyName
		} else {
			name = ""
		}
		
		return name
	}

	func getContactPrimaryPhone(for contact: CNContact) -> String {
		let userPhoneNumbers: [CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
		var phone: String
		
		//check for phone numbers and set values
		if userPhoneNumbers.count > 0 {
			let firstPhoneNumber = userPhoneNumbers[0].value
			phone = firstPhoneNumber.stringValue
		} else {
			phone = ""
		}
		
		return phone
	}

	func getContactSecondaryPhone(for contact: CNContact) -> String {
		let userPhoneNumbers: [CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
		var secondary_phone: String
			
		if userPhoneNumbers.count > 1 {
			let secondPhoneNumber = userPhoneNumbers[1].value
			secondary_phone = secondPhoneNumber.stringValue
		} else {
			secondary_phone = ""
		}
		
		return secondary_phone
	}

	func getContactPrimaryEmail(for contact: CNContact) -> String {
		let emailAddresses = contact.emailAddresses
		var email: String
		
		if emailAddresses.count > 0 {
			let firstEmail = emailAddresses[0].value
			email = firstEmail as String
		} else {
			email = ""
		}
		
		return email
	}

	func getContactSecondaryEmail(for contact: CNContact) -> String {
		let emailAddresses = contact.emailAddresses
		var secondary_email: String
		
		if emailAddresses.count > 1 {
			let secondEmail = emailAddresses[1].value
			secondary_email = secondEmail as String
		} else {
			secondary_email = ""
		}
		
		return secondary_email
	}

	func getContactPrimaryAddress(for contact: CNContact) -> String {
		//contact postal address array
		let addresses = contact.postalAddresses
		var address: String
		
		//check for postal addresses and set values
		if addresses.count > 0 {
			let firstAddress = addresses[0].value
			let fullAddress = firstAddress.street + ", " + firstAddress.city + ", " + firstAddress.state + " " + firstAddress.postalCode
			address = fullAddress.replacingOccurrences(of: "\n", with: " ")
		} else {
			address = ""
		}
		
		return address
	}

	func getContactSecondaryAddress(for contact: CNContact) -> String {
		//contact postal address array
		let addresses = contact.postalAddresses
		var secondary_address: String
		
		//check for postal addresses and set values
		if addresses.count > 1 {
			let secondAddress = addresses[1].value
			let fullAddress = secondAddress.street + ", " + secondAddress.city + ", " + secondAddress.state + " " + secondAddress.postalCode
			secondary_address = fullAddress.replacingOccurrences(of: "\n", with: " ")
		} else {
			secondary_address = ""
		}
		
		return secondary_address
	}

	func getContactBirthday(for contact: CNContact) -> String {
		var birthday:String
		
		if contact.birthday != nil {
			
			let birthdayDate = contact.birthday?.date
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MM-dd-yyyy"
			
			birthday = formatter.string(from: birthdayDate!)
			
			let month = DateFormatter()
			month.dateFormat = "MM-"
			let year = DateFormatter()
			year.dateFormat = "-yyyy"
			
			//contacts is returning a birthday and anniversary that is one day before the actual day...
			//pull out the substring day from  from the full date
			let start = birthday.index(birthday.startIndex, offsetBy: 3)
			let end = birthday.index(birthday.endIndex, offsetBy: -5)
			let range = start..<end
			
			//increment the day by one
			let daySubstring = birthday[range]  //day of the anniversary
			var dayInt = Int(daySubstring)!
			dayInt = dayInt+1
			let newDay = "\(dayInt)"
			
			//add the new full date as the birthday
			//scrapped the year in case they didn't set one, and I don't want to deal with that
			birthday = month.string(from: birthdayDate!) + newDay
			
		} else {
			birthday = ""
		}
		
		return birthday
	}

	func getContactAnniversary(for contact: CNContact) -> String {
		//check for anniversary and set value for anniversary and reminder preference
		var anniversary: String
		
		let anniversaryDate = contact.dates.filter { date -> Bool in
			
			guard let label = date.label else {
				return false
			}
			
			return label.contains("Anniversary")
			
			} .first?.value as DateComponents?
		
		if anniversaryDate?.date != nil {
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MM-dd-yyyy"
			
			anniversary = formatter.string(from: (anniversaryDate?.date!)!)
			
			let month = DateFormatter()
			month.dateFormat = "MM-"
			let year = DateFormatter()
			year.dateFormat = "-yyyy"
			
			//contacts is returning a birthday and anniversary that is one day before the actual day...
			//pull out the substring day from the full date
			let start = anniversary.index(anniversary.startIndex, offsetBy: 3)
			let end = anniversary.index(anniversary.endIndex, offsetBy: -5)
			let range = start..<end
			
			//increment the day by one
			let daySubstring = anniversary[range]  //day of the anniversary
			var dayInt = Int(daySubstring)!
			dayInt = dayInt+1
			let newDay = "\(dayInt)"
			
			//add the new full date as the anniversary
			//scrapped the year in case they didn't set one, and I don't want to deal with that
			anniversary = month.string(from: (anniversaryDate?.date!)!) + newDay
			
		} else {
			anniversary = ""
		}
		
		return anniversary
	}

}
