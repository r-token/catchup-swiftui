//
//  ContentView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import ContactsUI
import StoreKit
import SwiftData
import SwiftUI

struct HomeScreen : View {
    @Environment(\.modelContext) var modelContext
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.requestReview) var requestReview

    @Query(sort: \SelectedContact.name) var selectedContacts: [SelectedContact]
    @Query(sort: \SelectedContact.next_notification_date_time) var nextCatchups: [SelectedContact]

    @AppStorage("savedVersion") var savedVersion = "2.0.0"
    @AppStorage("timesUserHasLaunchedApp") var timesUserHasLaunchedApp = 0

    @State private var isColdLaunch = true
	@State private var isShowingUpdatesSheet = false
    @State private var isShowingAboutSheet = false
    @State private var shouldNavigateViaGrid = false
    @State private var tappedGridContact: SelectedContact? = nil
    @State private var contactPicker = ContactPickerDelegate()

    var filteredNextCatchups: [SelectedContact] {
        withAnimation {
            return Array(nextCatchups.filter({ $0.next_notification_date_time != "" }).prefix(4))
        }
    }

    @MainActor
	init() {
        //Use this if NavigationBarTitle is with Large Font
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemOrange]
    }
	
    var body: some View {
        VStack {
            List {
                Section("Next CatchUps") {
                    NextCatchUpsGridView(nextCatchUps: filteredNextCatchups, shouldNavigateViaGrid: $shouldNavigateViaGrid, tappedGridContact: $tappedGridContact)
                }

                Section("All CatchUps") {
                    ForEach(selectedContacts) { contact in
                        NavigationLink(destination: DetailScreen(contact: contact)) {
                            ContactRowView(contact: contact)
                        }
                    }
                    .onDelete(perform: removePendingNotificationsAndDeleteContact)
                }
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
        }
        .navigationBarTitle("CatchUp")

        .onAppear {
            clearNotificationBadgeAndCheckForUpdate()
            NotificationHelper.requestAuthorizationForNotifications()

            if isColdLaunch {
                if timesUserHasLaunchedApp > 5 && Int.random(in: 1...3) == 2 {
                    requestReview()
                }

                NotificationHelper.resetNotifications(for: selectedContacts, delayTime: 3)
                timesUserHasLaunchedApp += 1
            }
        }

        .onChange(of: scenePhase) { initialPhase, newPhase in
            if newPhase == .active {
                Utils.clearNotificationBadge()
                if !isColdLaunch {
                    NotificationHelper.resetNotifications(for: selectedContacts, delayTime: 3)
                    updateNextNotificationTime(for: selectedContacts)
                }
                isColdLaunch = false
            }
        }

        .sheet(isPresented: $isShowingUpdatesSheet) {
            UpdatesScreen()
        }

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
                        .foregroundStyle(.blue)
                }
                .sheet(isPresented: $isShowingAboutSheet) {
                    AboutScreen()
                }
            }
        }

        .navigationDestination(isPresented: $shouldNavigateViaGrid) {
            if let tappedGridContact {
                DetailScreen(contact: tappedGridContact)
            }
        }
    }

    @MainActor
    func openContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self.contactPicker
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        window?.rootViewController?.present(contactPicker, animated: true, completion: nil)
    }

    func updateNextNotificationTime(for contacts: [SelectedContact]) {
        print("updating next notification time for all contacts")
        for contact in contacts {
            let nextNotificationDateTime = NotificationHelper.getNextNotificationDateFor(contact: contact)
            contact.next_notification_date_time = nextNotificationDateTime
        }
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
            if Utils.updateIsMajor() && timesUserHasLaunchedApp > 0 {
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
