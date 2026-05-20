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

/// Sendable snapshot of the fields we pull off `CNContact`, so a Contacts
/// lookup can happen off the main actor and the values can be ferried back
/// without dragging the non-Sendable `CNContact` across the boundary.
struct ContactSnapshot: Sendable {
    var name: String
    var phone: String
    var secondaryPhone: String
    var email: String
    var secondaryEmail: String
    var address: String
    var secondaryAddress: String
    var picture: String
    var birthday: String
    var anniversary: String
}

// Functions for creating and updating a contact
struct ContactHelper {
    nonisolated static func encodeContactPicture(for contact: CNContact) -> String {
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

    nonisolated static func getContactName(for contact: CNContact) -> String {
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

    nonisolated static func getContactPrimaryPhone(for contact: CNContact) -> String {
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

    nonisolated static func getContactSecondaryPhone(for contact: CNContact) -> String {
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

    nonisolated static func getContactPrimaryEmail(for contact: CNContact) -> String {
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

    nonisolated static func getContactSecondaryEmail(for contact: CNContact) -> String {
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

    nonisolated static func getContactPrimaryAddress(for contact: CNContact) -> String {
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

    nonisolated static func getContactSecondaryAddress(for contact: CNContact) -> String {
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

    nonisolated static func getContactBirthday(for contact: CNContact) -> String {
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

    nonisolated static func getContactAnniversary(for contact: CNContact) -> String {
		//check for anniversary and set value for anniversary and reminder preference
		var anniversaryString: String
		
		let anniversary = contact.dates.filter { date -> Bool in
			guard let label = date.label else {
				return false
			}
			return label.contains("Anniversary")
        } .first?.value as DateComponents?
		
        if let anniversaryDate = anniversary?.date {
			let formatter = DateFormatter()
			formatter.dateFormat = "MM-dd"
			formatter.locale = Locale(identifier: "en_US_POSIX")
			formatter.timeZone = TimeZone(secondsFromGMT: 0)

			anniversaryString = formatter.string(from: anniversaryDate)
		} else {
			anniversaryString = ""
		}
		
		return anniversaryString
	}

    static func getFirstName(for contact: SelectedContact) -> String {
        contact.name.components(separatedBy: " ").first ?? contact.name
    }

    static func getFriendlyNextCatchUpTime(for contact: SelectedContact, forQuarterlyPreference: Bool) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        if let date = dateFormatter.date(from: contact.next_notification_date_time) {
            let friendlyFormatter = DateFormatter()

            if forQuarterlyPreference {
                friendlyFormatter.dateFormat = "h:mm a"
                return "Quarterly at \(friendlyFormatter.string(from: date))"
            }

            if Calendar.current.isDateInToday(date) {
                friendlyFormatter.dateFormat = "h:mm a"
                return "Today at \(friendlyFormatter.string(from: date))"
            } else if Calendar.current.isDateInTomorrow(date) {
                friendlyFormatter.dateFormat = "h:mm a"
                return "Tomorrow at \(friendlyFormatter.string(from: date))"
            } else {
                friendlyFormatter.dateFormat = "MMMM d 'at' h:mm a"
                return friendlyFormatter.string(from: date)
            }
        } else {
            return "None"
        }
    }

    static func createSelectedContact(contact: CNContact) -> SelectedContact {
        let currentMinute = Calendar.current.component(.minute, from: Date())
        let currentHour = Calendar.current.component(.hour, from: Date())
        let currentDay = Calendar.current.component(.day, from: Date())
        let currentMonth = Calendar.current.component(.month, from: Date())
        let currentYear = Calendar.current.component(.year, from: Date())
        let currentWeekOfMonth = Calendar.current.component(.weekOfMonth, from: Date())

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
        let notification_preference_quarterly_set_time = Date()
        let notification_preference_weekday = 1
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
            notification_preference_quarterly_set_time: notification_preference_quarterly_set_time,
            notification_preference_weekday: notification_preference_weekday,
            notification_preference_week_of_month: currentWeekOfMonth,
            phone: phone,
            picture: picture,
            secondary_address: secondary_address,
            secondary_email: secondary_email,
            secondary_phone: secondary_phone,
            unread_badge_date_time: ""
        )

        return selectedContact
    }

    static func updateSelectedContacts(_ selectedContacts: [SelectedContact]) async {
        // Look up snapshots in parallel off the main actor, then apply on main.
        let names = selectedContacts.map(\.name)

        let snapshotsByName: [String: ContactSnapshot] = await withTaskGroup(
            of: (String, ContactSnapshot?).self
        ) { group in
            for name in names {
                group.addTask { (name, await getContactSnapshot(byName: name)) }
            }
            var result: [String: ContactSnapshot] = [:]
            for await (name, snapshot) in group {
                if let snapshot { result[name] = snapshot }
            }
            return result
        }

        for contact in selectedContacts {
            if let snapshot = snapshotsByName[contact.name] {
                apply(snapshot, to: contact)
            } else {
                print("No contact with name \(contact.name) found")
            }
        }
    }

    static func updateSelectedContact(_ selectedContact: SelectedContact?) async {
        guard let selectedContact else { return }

        if let snapshot = await getContactSnapshot(byName: selectedContact.name) {
            apply(snapshot, to: selectedContact)
        } else {
            print("No contact with name \(selectedContact.name) found")
        }
    }

    private static func apply(_ snapshot: ContactSnapshot, to selectedContact: SelectedContact) {
        let nextNotificationDateTime = NotificationHelper.getNextNotificationDateFor(contact: selectedContact)

        selectedContact.name = snapshot.name
        selectedContact.phone = snapshot.phone
        selectedContact.secondary_phone = snapshot.secondaryPhone
        selectedContact.email = snapshot.email
        selectedContact.secondary_email = snapshot.secondaryEmail
        selectedContact.address = snapshot.address
        selectedContact.secondary_address = snapshot.secondaryAddress
        selectedContact.picture = snapshot.picture
        selectedContact.birthday = snapshot.birthday
        selectedContact.anniversary = snapshot.anniversary
        selectedContact.next_notification_date_time = nextNotificationDateTime
    }

    /// Looks up a `CNContact` by name and returns a `Sendable` snapshot of its fields.
    /// Runs on the concurrent pool so it doesn't block the main actor during the
    /// synchronous `unifiedContacts` query.
    @concurrent
    nonisolated static func getContactSnapshot(byName name: String) async -> ContactSnapshot? {
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

        do {
            let predicate = CNContact.predicateForContacts(matchingName: name)
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)

            let nameFormatter = CNContactFormatter()
            nameFormatter.style = .fullName

            guard let contact = contacts.first(where: { nameFormatter.string(from: $0) == name }) else {
                return nil
            }

            print("Found matching contact: \(contact.givenName)")
            return ContactSnapshot(
                name: getContactName(for: contact),
                phone: getContactPrimaryPhone(for: contact),
                secondaryPhone: getContactSecondaryPhone(for: contact),
                email: getContactPrimaryEmail(for: contact),
                secondaryEmail: getContactSecondaryEmail(for: contact),
                address: getContactPrimaryAddress(for: contact),
                secondaryAddress: getContactSecondaryAddress(for: contact),
                picture: encodeContactPicture(for: contact),
                birthday: getContactBirthday(for: contact),
                anniversary: getContactAnniversary(for: contact)
            )
        } catch {
            print("Unable to fetch contacts: \(error)")
            return nil
        }
    }
}
