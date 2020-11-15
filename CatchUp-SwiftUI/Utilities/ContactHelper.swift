//
//  ContactHelper.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 11/15/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import Foundation
import ContactsUI
import CoreData

struct ContactHelper {
	// save selected contacts and their properties to Core Data
	func saveSelectedContact(for contacts: [CNContact]) {
		print("saving...")
		
		let contactService = ContactService()
		for contact in contacts {
			let currentMinute = Calendar.current.component(.minute, from: Date())
			let currentHour = Calendar.current.component(.hour, from: Date())
			let currentDay = Calendar.current.component(.day, from: Date())
			let currentMonth = Calendar.current.component(.month, from: Date())
			let currentYear = Calendar.current.component(.year, from: Date())
			
			let id = UUID()
			let address = contactService.getContactPrimaryAddress(for: contact)
			let anniversary = contactService.getContactAnniversary(for: contact)
			let anniversary_notification_ID = UUID()
			let birthday = contactService.getContactBirthday(for: contact)
			let birthday_notification_ID = UUID()
			let email = contactService.getContactPrimaryEmail(for: contact)
			let name = contactService.getContactName(for: contact)
			let notification_identifier = UUID()
			let notification_preference = 0
			let notification_preference_hour = currentHour
			let notification_preference_minute = currentMinute
			let notification_preference_weekday = 0
			let notification_preference_custom_year = currentYear
			let notification_preference_custom_month = currentMonth
			let notification_preference_custom_day = currentDay
			let phone = contactService.getContactPrimaryPhone(for: contact)
			let picture = contactService.encodeContactPicture(for: contact)
			let secondary_email = contactService.getContactSecondaryEmail(for: contact)
			let secondary_address = contactService.getContactSecondaryAddress(for: contact)
			let secondary_phone = contactService.getContactSecondaryPhone(for: contact)
			
			if !contactAlreadyAdded(name: name) {
				guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
					return
				}
				
				let managedObjectContext = appDelegate.persistentContainer.viewContext
				let entity = NSEntityDescription.entity(forEntityName: "SelectedContact", in: managedObjectContext)!
				
				let selectedContact = NSManagedObject(entity: entity, insertInto: managedObjectContext)
				
				selectedContact.setValue(id, forKeyPath: "id")
				selectedContact.setValue(address, forKeyPath: "address")
				selectedContact.setValue(anniversary, forKeyPath: "anniversary")
				selectedContact.setValue(anniversary_notification_ID, forKeyPath: "anniversary_notification_id")
				selectedContact.setValue(birthday, forKeyPath: "birthday")
				selectedContact.setValue(birthday_notification_ID, forKeyPath: "birthday_notification_id")
				selectedContact.setValue(email, forKeyPath: "email")
				selectedContact.setValue(name, forKeyPath: "name")
				selectedContact.setValue(notification_identifier, forKeyPath: "notification_identifier")
				selectedContact.setValue(notification_preference, forKeyPath: "notification_preference")
				selectedContact.setValue(notification_preference_hour, forKeyPath: "notification_preference_hour")
				selectedContact.setValue(notification_preference_minute, forKeyPath: "notification_preference_minute")
				selectedContact.setValue(notification_preference_weekday, forKeyPath: "notification_preference_weekday")
				selectedContact.setValue(notification_preference_custom_year, forKeyPath: "notification_preference_custom_year")
				selectedContact.setValue(notification_preference_custom_month, forKeyPath: "notification_preference_custom_month")
				selectedContact.setValue(notification_preference_custom_day, forKeyPath: "notification_preference_custom_day")
				selectedContact.setValue(phone, forKeyPath: "phone")
				selectedContact.setValue(picture, forKeyPath: "picture")
				selectedContact.setValue(secondary_address, forKeyPath: "secondary_address")
				selectedContact.setValue(secondary_email, forKeyPath: "secondary_email")
				selectedContact.setValue(secondary_phone, forKeyPath: "secondary_phone")
				
				do {
					try managedObjectContext.save()
				} catch let error as NSError {
					print("Could not save. \(error), \(error.userInfo)")
				}
			} else {
				print("Do nothing. Contact was already added to the database")
			}
		}
		
	}
	
	func contactAlreadyAdded(name: String) -> Bool {
		print("Checking \(name)")
		guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
			return true
		}
		let managedObjectContext = appDelegate.persistentContainer.viewContext
		
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SelectedContact")
		fetchRequest.predicate = NSPredicate(format: "name = %@", name)

		var contactsWithThatName = 0

		do {
			contactsWithThatName = try managedObjectContext.count(for: fetchRequest)
		}
		catch {
			print("error executing fetch request: \(error)")
		}

		print("contacts with that name: \(contactsWithThatName)")
		return contactsWithThatName > 0
	}
}
