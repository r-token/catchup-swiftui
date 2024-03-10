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

struct HomeScreen : View {
    @Environment(\.modelContext) var modelContext
    @Query(sort: \SelectedContact.name) var selectedContacts: [SelectedContact]

    @AppStorage("savedVersion") var savedVersion = "2.0.0"

    @State private var isColdLaunch = true
    @State private var isShowingContactPicker = false
	@State private var isShowingUpdatesSheet = false
    @State private var isShowingAboutSheet = false

    @State private var contactPicker = ContactPicker()

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
                .onChange(of: contactPicker.chosenContacts) { initialContacts, contacts in
                    if !contacts.isEmpty {
                        saveSelectedContact(for: contacts)
                    }
                    contactPicker.chosenContacts = []
                }

                Button(action: {
                    openContactPicker()
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
//                .sheet(isPresented: $isShowingContactPicker) {
//                    ContactPicker(
//                        showPicker: $isShowingContactPicker,
//                        onSelectContacts: { selectedContacts in
//                            saveSelectedContact(for: selectedContacts)
//                        }
//                    )
//                }

				.navigationBarTitle(Text("CatchUp"))
					
				.navigationBarItems(trailing:
					Button {
						isShowingAboutSheet = true
                    } label: {
						Image(systemName: "ellipsis.circle")
							.font(.title2)
							.foregroundColor(.blue)
					}
                    .sheet(isPresented: $isShowingAboutSheet) {
                        AboutScreen()
                    }
				)
            }
		}
		.accentColor(.orange)

        .onAppear {
            print("HomeScreen onAppear")
            clearNotificationBadgeAndCheckForUpdate()
            notificationService.requestAuthorizationForNotifications()

            if isColdLaunch {
                resetNotifications()
                isColdLaunch = false
            }

            print(modelContext.sqliteCommand)
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
        print("latest version: \(version)")

        if savedVersion == version {
            print("App is up to date!")
        } else {
			if updateIsMajor() {
				// Toggle to show UpdatesScreen as a sheet
				print("Major update detected, showing UpdatesScreen...")
				isShowingUpdatesSheet = true
			}
            savedVersion = version
        }
    }

    func openContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self.contactPicker
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        window?.rootViewController?.present(contactPicker, animated: true, completion: nil)
    }

    func resetNotifications() {
        for contact in selectedContacts {
            notificationService.removeExistingNotifications(for: contact)
            notificationService.createNewNotification(for: contact, modelContext: modelContext)
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
                    notification_preference: notification_preference,
                    notification_preference_custom_day: notification_preference_custom_day,
                    notification_preference_custom_month: notification_preference_custom_month,
                    notification_preference_custom_year: notification_preference_custom_year,
                    notification_preference_hour: notification_preference_hour,
                    notification_preference_minute: notification_preference_minute,
                    notification_preference_weekday: notification_preference_weekday,
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

#Preview {
    HomeScreen()
}
