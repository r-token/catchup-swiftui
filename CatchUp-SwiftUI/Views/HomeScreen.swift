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
	@State private var isShowingUpdatesSheet = false
    @State private var isShowingAboutSheet = false
    @State private var contactPicker = ContactPickerDelegate()

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
							ContactRowView(contact: contact)
						}
					}
                    .onDelete(perform: removePendingNotificationsAndDeleteContact)
				}
                .refreshable {
                    ContactHelper.updateSelectedContacts(selectedContacts)
                }

                .onChange(of: contactPicker.chosenContacts) { initialContacts, contacts in
                    if !contacts.isEmpty {
                        saveSelectedContact(for: contacts)
                    }
                    contactPicker.chosenContacts = []
                }

                Button {
                    openContactPicker()
                } label: {
					OpenContactPickerButtonView()
                }

				.navigationBarTitle("CatchUp")
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        EditButton()
                            .foregroundStyle(.blue)
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            isShowingAboutSheet = true
                        } label: {
                            Image(systemName: "person.crop.square")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $isShowingAboutSheet) {
                            AboutScreen()
                        }
                    }
                }
            }
		}
		.accentColor(.orange)

        .onAppear {
            print("sqlite path: \(modelContext.sqliteCommand)")
            clearNotificationBadgeAndCheckForUpdate()
            NotificationHelper.requestAuthorizationForNotifications()

            if isColdLaunch {
                NotificationHelper.resetNotifications(for: selectedContacts, modelContext: modelContext)
                isColdLaunch = false
            }
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

    // save selected contacts and their properties to SwiftData
    func saveSelectedContact(for contacts: [CNContact]) {
        for contact in contacts {
            let contactName = ContactHelper.getContactName(for: contact)
            if !contactAlreadyAdded(name: contactName) {
                let selectedContact = ContactHelper.createSelectedContact(contact: contact)
                modelContext.insert(selectedContact)
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

    func clearNotificationBadgeAndCheckForUpdate() {
        Utils.fetchAvailableIAPs()
        Utils.clearNotificationBadge()

        checkForUpdate()
    }
    
    func removePendingNotificationsAndDeleteContact(at offsets: IndexSet) {
        for index in offsets {
            let contact = selectedContacts[index]
            
            NotificationHelper.removeExistingNotifications(for: contact)
            modelContext.delete(contact)
        }
    }
    
    func checkForUpdate() {
        let version = Utils.getCurrentAppVersion()
        print("latest version: \(version)")

        if savedVersion == version {
            print("App is up to date!")
        } else {
            if Utils.updateIsMajor() {
				// Toggle to show UpdatesScreen as a sheet
				print("Major update detected, showing UpdatesScreen...")
				isShowingUpdatesSheet = true
			}
            savedVersion = version
        }
    }
}

#Preview {
    HomeScreen()
}
