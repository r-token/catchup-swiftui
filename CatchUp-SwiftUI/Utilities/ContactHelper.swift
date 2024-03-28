//
//  ContactHelper.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import UIKit
import Contacts
import CoreData

struct ContactHelper {
    // MARK: Functions for DetailScreen
    
    static func contactHasPhone(_ contact: SelectedContact) -> Bool {
        return contact.phone != "" ? true : false
    }
    
    static func contactHasSecondaryPhone(_ contact: SelectedContact) -> Bool {
        return contact.secondary_phone != "" ? true : false
    }
    
    static func contactHasEmail(_ contact: SelectedContact) -> Bool {
        return contact.email != "" ? true : false
    }
    
    static func contactHasSecondaryEmail(_ contact: SelectedContact) -> Bool {
        return contact.secondary_email != "" ? true : false
    }
    
    static func contactHasAddress(_ contact: SelectedContact) -> Bool {
        return contact.address != "" ? true : false
    }
    
    static func contactHasSecondaryAddress(_ contact: SelectedContact) -> Bool {
        return contact.secondary_address != "" ? true : false
    }

    static func contactHasBirthday(_ contact: SelectedContact) -> Bool {
        return contact.birthday != "" ? true : false
    }

    static func contactHasAnniversary(_ contact: SelectedContact) -> Bool {
        return contact.anniversary != "" ? true : false
    }

    // MARK: Functions for ContactPickerViewController
    
    static func encodeContactPicture(for contact: CNContact) -> String {
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

    static func getContactName(for contact: CNContact) -> String {
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

    static func getContactPrimaryPhone(for contact: CNContact) -> String {
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

    static func getContactSecondaryPhone(for contact: CNContact) -> String {
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

    static func getContactPrimaryEmail(for contact: CNContact) -> String {
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

    static func getContactSecondaryEmail(for contact: CNContact) -> String {
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

    static func getContactPrimaryAddress(for contact: CNContact) -> String {
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

    static func getContactSecondaryAddress(for contact: CNContact) -> String {
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

    static func getContactBirthday(for contact: CNContact) -> String {
		var birthdayString: String
		
		if contact.birthday != nil {
			
			let birthday = contact.birthday?.date
			
			let formatter = DateFormatter()
			formatter.dateFormat = "MM-dd"
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone(secondsFromGMT: 0)
			
			birthdayString = formatter.string(from: birthday!)
			
			let birthdayDate = formatter.date(from: birthdayString)!
			birthdayString = formatter.string(from: birthdayDate)
			
		} else {
			birthdayString = ""
		}
		
		return birthdayString
	}

    static func getContactAnniversary(for contact: CNContact) -> String {
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
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone(secondsFromGMT: 0)
			
			anniversaryString = formatter.string(from: (anniversary?.date!)!)
			
			let anniversaryDate = formatter.date(from: anniversaryString)!
			anniversaryString = formatter.string(from: anniversaryDate)
			
		} else {
			anniversaryString = ""
		}
		
		return anniversaryString
	}

    static func createSelectedContact(contact: CNContact) -> SelectedContact {
        let currentMinute = Calendar.current.component(.minute, from: Date())
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentWeekOfMonth = Calendar.current.component(.weekOfYear, from: Date())

        let id = UUID()
        let address = ContactHelper.getContactPrimaryAddress(for: contact)
        let anniversary = ContactHelper.getContactAnniversary(for: contact)
        let anniversary_notification_ID = UUID()
        let birthday = ContactHelper.getContactBirthday(for: contact)
        let birthday_notification_ID = UUID()
        let email = ContactHelper.getContactPrimaryEmail(for: contact)
        let name = ContactHelper.getContactName(for: contact)
        let notification_identifier = UUID()
        let notification_preference = 0
        let notification_preference_hour = currentHour
        let notification_preference_minute = currentMinute
        let notification_preference_weekday = 0
        let notification_preference_custom_year = currentYear
        let notification_preference_custom_month = currentMonth
        let notification_preference_custom_day = currentDay
        let phone = ContactHelper.getContactPrimaryPhone(for: contact)
        let picture = ContactHelper.encodeContactPicture(for: contact)
        let secondary_email = ContactHelper.getContactSecondaryEmail(for: contact)
        let secondary_address = ContactHelper.getContactSecondaryAddress(for: contact)
        let secondary_phone = ContactHelper.getContactSecondaryPhone(for: contact)

        let selectedContact = SelectedContact(
            address: address,
            anniversary: anniversary,
            anniversary_notification_id: anniversary_notification_ID,
            birthday: birthday,
            birthday_notification_id: birthday_notification_ID,
            email: email,
            id: id,
            name: name,
            next_notification_date_time: "",
            notification_identifier: notification_identifier,
            notification_preference: notification_preference,
            notification_preference_custom_day: notification_preference_custom_day,
            notification_preference_custom_month: notification_preference_custom_month,
            notification_preference_custom_year: notification_preference_custom_year,
            notification_preference_hour: notification_preference_hour,
            notification_preference_minute: notification_preference_minute,
            notification_preference_weekday: notification_preference_weekday,
            notification_preference_week_of_month: currentWeekOfMonth,
            phone: phone,
            picture: picture,
            secondary_address: secondary_address,
            secondary_email: secondary_email,
            secondary_phone: secondary_phone
        )

        return selectedContact
    }

    static func updateSelectedContacts(_ selectedContacts: [SelectedContact]) {
        for contact in selectedContacts {
            updateSelectedContact(contact)
        }
    }

    static func updateSelectedContact(_ selectedContact: SelectedContact?) {
        guard let selectedContact else { return }

        getCNContactByName(selectedContact.name) { contact in
            if let contact {
                let nextNotificationDateTime = NotificationHelper.getNextNotificationDateFor(contact: selectedContact)

                selectedContact.name = getContactName(for: contact)
                selectedContact.phone = getContactPrimaryPhone(for: contact)
                selectedContact.secondary_phone = getContactSecondaryPhone(for: contact)
                selectedContact.email = getContactPrimaryEmail(for: contact)
                selectedContact.secondary_email = getContactSecondaryEmail(for: contact)
                selectedContact.address = getContactPrimaryAddress(for: contact)
                selectedContact.secondary_address = getContactSecondaryAddress(for: contact)
                selectedContact.picture = encodeContactPicture(for: contact)
                selectedContact.birthday = getContactBirthday(for: contact)
                selectedContact.anniversary = getContactAnniversary(for: contact)
                selectedContact.next_notification_date_time = nextNotificationDateTime
            } else {
                print("No contact with name \(selectedContact.name) found")
            }
        }
    }

    static func getCNContactByName(_ name: String, completion: @escaping (CNContact?) -> Void) {
        print("searching contact book for \(name)")
        
        let contactStore = CNContactStore()
        let keysToFetch: [CNKeyDescriptor] = [
            CNContactFormatter.descriptorForRequiredKeys(for: .fullName),
            CNContactGivenNameKey as CNKeyDescriptor,
            CNContactFamilyNameKey as CNKeyDescriptor,
            CNContactPhoneNumbersKey as CNKeyDescriptor,
            CNContactEmailAddressesKey as CNKeyDescriptor,
            CNContactPostalAddressesKey as CNKeyDescriptor,
            CNContactImageDataAvailableKey as CNKeyDescriptor,
            CNContactImageDataKey as CNKeyDescriptor,
            CNContactThumbnailImageDataKey as CNKeyDescriptor,
            CNContactBirthdayKey as CNKeyDescriptor,
            CNContactDatesKey as CNKeyDescriptor
        ]

        DispatchQueue.global(qos: .background).async {
            var allContacts: [CNContact] = []

            do {
                try contactStore.enumerateContacts(with: CNContactFetchRequest(keysToFetch: keysToFetch)) { (contact, stop) in
                    allContacts.append(contact)
                }
            } catch {
                print("Unable to fetch contacts")
                DispatchQueue.main.async {
                    completion(nil)
                }
                return
            }

            let nameFormatter = CNContactFormatter()
            nameFormatter.style = .fullName

            let filteredContacts = allContacts.filter { contact in
                return nameFormatter.string(from: contact) == name
            }

            print("Found matching contact: \(filteredContacts.first?.givenName ?? "Unknown")")

            DispatchQueue.main.async {
                completion(filteredContacts.first)
            }
        }
    }
}
