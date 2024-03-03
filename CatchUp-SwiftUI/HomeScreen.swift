//
//  ContentView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import SwiftData
import SwiftUI
import SwiftUIKit
import ContactsUI

enum ActiveSheet: Identifiable {
	case contactPicker
    case about
    case updates
	
	var id: UUID {
		UUID()
	}
}

struct HomeScreen : View {
	@State private var showSheet = false
	@State private var showContactPicker = false
	@State private var contacts: [CNContact] = []
	@State private var activeSheet: ActiveSheet?
    @State private var showUpdates: ActiveSheet = .updates

	@Environment(\.modelContext) var modelContext
    @Query(sort: \SelectedContact.name) var selectedContacts: [SelectedContact]
	
    let notificationService = NotificationService()
    let helper = GeneralHelpers()
	let converter = Conversions()
	
	init() {
        //Use this if NavigationBarTitle is with Large Font
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemOrange]
    }
	
    var body: some View {
        NavigationView {
            VStack {
                List {
					ForEach(selectedContacts) { contact in
						NavigationLink(destination: DetailScreen(contact: contact)) {
							HStack {
                                converter.getContactPicture(from: contact.picture)
									.renderingMode(.original)
									.resizable()
									.frame(width: 45, height: 45, alignment: .leading)
									.clipShape(Circle())
								
								VStack(alignment: .leading, spacing: 2) {
									Text(contact.name)
										.font(.headline)
									Text(converter.convertNotificationPreferenceIntToString(preference: Int(contact.notification_preference), contact: contact))
										.font(.caption)
										.foregroundColor(.gray)
								}
							}
						}
					}
                    .onDelete(perform: removePendingNotificationsAndDeleteContact)
				}
                
                Button(action: {
					activeSheet = .contactPicker
					showContactPicker.toggle()
                }) {
					HStack(alignment: .center, spacing: 6) {
						Image(systemName: "person.crop.circle.fill.badge.plus")
						
						Text("Add Contacts")
					}
					.font(.headline)
					.foregroundColor(.blue)
					.padding(.top)
					.padding(.bottom)
                }
					
				.navigationBarTitle(Text("CatchUp"))
					
				.navigationBarItems(trailing:
					Button(action: {
						activeSheet = .about
					}) {
						Image(systemName: "ellipsis.circle")
							.font(.title2)
							.foregroundColor(.blue)
					}
				)
            }
				
			.sheet(item: $activeSheet, onDismiss: { activeSheet = nil }) { item in
				switch item {
				case .contactPicker:
					ContactPicker(
						showPicker: $showContactPicker,
						onSelectContacts: { c in
							contacts = c
							saveSelectedContact(for: contacts)
						}
					)
				case .about:
					AboutScreen()
				case .updates:
					UpdatesScreen()
				}
			}
		}
		.accentColor(.orange)
        .onAppear {
            clearNotificationBadgeAndCheckForUpdate()

            print("contacts: \(selectedContacts)")
        }
    }
    
    func clearNotificationBadgeAndCheckForUpdate() {
		fetchAvailableIAPs()
        helper.clearNotificationBadge()
        try? modelContext.save()
        checkForUpdate()
    }
    
    func removePendingNotificationsAndDeleteContact(at offsets: IndexSet) {
        for index in offsets {
            let contact = selectedContacts[index]
            
            notificationService.removeExistingNotifications(for: contact)
            modelContext.delete(contact)
        }
    }
    
    func checkForUpdate() {
        let version = helper.getCurrentAppVersion()
        let savedVersion = UserDefaults.standard.string(forKey: "savedVersion")

        if savedVersion == version {
            print("App is up to date!")
        } else {
			if updateIsMajor() {
				// Toggle to show UpdatesScreen as a sheet
				print("Major update detected, showing UpdatesScreen...")
				activeSheet = .updates
			}
            UserDefaults.standard.set(version, forKey: "savedVersion")
        }
    }
	
	func updateIsMajor() -> Bool {
		let version = helper.getCurrentAppVersion()
		if version.suffix(2) == ".0" {
			return true
		} else {
			return false
		}
	}
	
	func fetchAvailableIAPs() {
		print("fetching IAPs")
		IAPService.shared.fetchAvailableProducts()
	}

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
                let selectedContact = SelectedContact(
                    address: address,
                    anniversary: anniversary,
                    anniversary_notification_id: anniversary_notification_ID,
                    birthday: birthday,
                    birthday_notification_id: birthday_notification_ID,
                    email: email,
                    id: id,
                    name: name,
                    notification_identifier: notification_identifier,
                    notification_preference: Int16(notification_preference),
                    notification_preference_custom_day: Int16(notification_preference_custom_day),
                    notification_preference_custom_month: Int16(notification_preference_custom_month),
                    notification_preference_custom_year: Int16(notification_preference_custom_year),
                    notification_preference_hour: Int16(notification_preference_hour),
                    notification_preference_minute: Int16(notification_preference_minute),
                    notification_preference_weekday: Int16(notification_preference_weekday),
                    phone: phone,
                    picture: picture,
                    secondary_address: secondary_address,
                    secondary_email: secondary_email,
                    secondary_phone: secondary_phone
                )

                modelContext.insert(selectedContact)
            } else {
                print("Do nothing. Contact was already added to the database")
            }
        }

    }

    func contactAlreadyAdded(name: String) -> Bool {
        for contact in selectedContacts {
            if contact.name == name {
                return true
            }
        }

        return false
    }
}

struct HomeScreen_Previews : PreviewProvider {
    static var previews: some View {
        return HomeScreen()
    }
}
