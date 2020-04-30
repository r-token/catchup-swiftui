//
//  ContactUtilityFunctions.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import UIKit
import Contacts
import CoreData

struct ContactService {
    
    // MARK: Functions for DetailScreen
    
    func contactHasPhone(_ contact: SelectedContact) -> Bool {
        return contact.phone != "" ? true : false
    }
    
    func contactHasSecondaryPhone(_ contact: SelectedContact) -> Bool {
        return contact.secondary_phone != "" ? true : false
    }
    
    func contactHasEmail(_ contact: SelectedContact) -> Bool {
        return contact.email != "" ? true : false
    }
    
    func contactHasSecondaryEmail(_ contact: SelectedContact) -> Bool {
        return contact.secondary_email != "" ? true : false
    }
    
    func contactHasAddress(_ contact: SelectedContact) -> Bool {
        return contact.address != "" ? true : false
    }
    
    func contactHasSecondaryAddress(_ contact: SelectedContact) -> Bool {
        return contact.secondary_address != "" ? true : false
    }
    
    // MARK: Functions for ContactPickerViewController
    
	func encodeContactPicture(for contact: CNContact) -> String {
		let picture: String
		
		if contact.imageDataAvailable == true {
			let dataPicture: NSData = contact.thumbnailImageData! as NSData
			picture = dataPicture.base64EncodedString()
		} else {
			// there is not an image for this contact, use the default image
			let image = UIImage(named: "DefaultPhoto")
			let imageData: NSData = image!.pngData()! as NSData
			picture = imageData.base64EncodedString()
		}
		
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
		var birthdayString: String
		
		if contact.birthday != nil {
			
			let birthday = contact.birthday?.date
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MM-dd"
			
			birthdayString = formatter.string(from: birthday!)
			
			// Contacts returns the day before the actual birthday for some reason
			// I need to get the next day and return that
			let birthdayDate = formatter.date(from: birthdayString)!
			let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: birthdayDate)
			birthdayString = formatter.string(from: nextDay!)
			
		} else {
			birthdayString = ""
		}
		
		return birthdayString
	}

	func getContactAnniversary(for contact: CNContact) -> String {
		//check for anniversary and set value for anniversary and reminder preference
		var anniversaryString: String
		
		let anniversary = contact.dates.filter { date -> Bool in
			
			guard let label = date.label else {
				return false
			}
			
			return label.contains("Anniversary")
			
			} .first?.value as DateComponents?
		
		if anniversary?.date != nil {
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MM-dd"
			
			anniversaryString = formatter.string(from: (anniversary?.date!)!)
			
			// Contacts returns the day before the actual birthday for some reason
			// I need to get the next day and return that
			let anniversaryDate = formatter.date(from: anniversaryString)!
			let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: anniversaryDate)
			anniversaryString = formatter.string(from: nextDay!)
			
		} else {
			anniversaryString = ""
		}
		
		return anniversaryString
	}

}
