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

struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.requestReview) private var requestReview

    @Query(sort: \SelectedContact.name) private var selectedContacts: [SelectedContact]
    @Query(sort: \SelectedContact.next_notification_date_time) private var nextCatchups: [SelectedContact]

    @AppStorage("savedVersion") private var savedVersion = "2.0.0"
    @AppStorage("timesUserHasLaunchedApp") private var timesUserHasLaunchedApp = 0
    // Bump the suffix to trigger a fresh full reset on the next launch (e.g. "_v4").
    @AppStorage("hasPerformedNuclearNotificationReset_v3") private var hasPerformedNuclearNotificationReset = false

    @State private var isColdLaunch = true
    @State private var isShowingUpdatesSheet = false
    @State private var isShowingAboutSheet = false
    @State private var tappedGridContact: SelectedContact?
    @State private var contactPicker = ContactPickerDelegate()

    init() {
        // No pure-SwiftUI API colors just the large nav title without
        // also tinting toolbar items, so style it via the appearance proxy.
        UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemOrange]
    }

    private var filteredNextCatchups: [SelectedContact] {
        Array(nextCatchups.lazy.filter { !$0.next_notification_date_time.isEmpty }.prefix(4))
    }

    private var hasAnyNotificationPreference: Bool {
        selectedContacts.contains { $0.notification_preference != 0 }
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            List {
                if selectedContacts.isEmpty {
                    ContentUnavailableView(
                        "No CatchUps Yet",
                        systemImage: "person.crop.circle.badge.plus",
                        description: Text("Tap the 'Add Contacts' button to add some.")
                    )
                    .listRowBackground(Color.clear)
                } else {
                    if hasAnyNotificationPreference {
                        Section("Next CatchUps") {
                            NextCatchUpsGridView(
                                nextCatchUps: filteredNextCatchups,
                                tappedGridContact: $tappedGridContact
                            )
                        }
                    }

                    Section("All CatchUps") {
                        ForEach(selectedContacts) { contact in
                            NavigationLink(value: contact) {
                                ContactRowView(contact: contact)
                            }
                        }
                        .onDelete(perform: removePendingNotificationsAndDeleteContact)
                    }
                }
            }
            .refreshable {
                await NotificationHelper.resetNotifications(for: selectedContacts, delayTime: 0)
                await ContactHelper.updateSelectedContacts(selectedContacts)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: 40)
            }
            .onChange(of: contactPicker.chosenContact) { _, newValue in
                if let contact = newValue {
                    saveSelectedContact(for: [contact])
                }
                contactPicker.chosenContact = nil
            }

            VStack {
                Spacer()
                GlassButton(action: openContactPicker) {
                    OpenContactPickerButtonView()
                }
            }
        }
        .navigationTitle("CatchUp")
        .navigationDestination(for: SelectedContact.self) { contact in
            DetailScreen(contact: contact)
        }
        .navigationDestination(item: $tappedGridContact) { contact in
            DetailScreen(contact: contact)
        }
        .onAppear(perform: handleAppear)
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                Utils.clearAppIconNotificationBadge()
                updateNextNotificationTime(for: selectedContacts)
            }
        }
        .sheet(isPresented: $isShowingUpdatesSheet) {
            UpdatesScreen()
        }
        .sheet(isPresented: $isShowingAboutSheet) {
            AboutScreen()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                EditButton()
                    .tint(.blue)
            }

            ToolbarItem(placement: .topBarTrailing) {
                Button("About", systemImage: "person.crop.square") {
                    isShowingAboutSheet = true
                }
                .tint(.blue)
            }
        }
    }

    private func handleAppear() {
        // Always clear badge when returning to home
        Utils.clearAppIconNotificationBadge()

        guard isColdLaunch else { return }
        isColdLaunch = false

        // Only check version on cold launch (IAPs load lazily when the tip jar appears)
        checkForUpdate()

        NotificationHelper.requestAuthorizationForNotifications()

        if timesUserHasLaunchedApp > 5 && Int.random(in: 1...3) == 2 {
            requestReview()
        }

        Task { @MainActor in
            if hasPerformedNuclearNotificationReset {
                // Defense-in-depth on every cold launch: cancel anything
                // whose identifier no longer corresponds to a contact in
                // SwiftData, then re-schedule for everyone who survives.
                await NotificationHelper.cleanupOrphanedNotifications(for: selectedContacts)
                await NotificationHelper.resetNotifications(for: selectedContacts, delayTime: 3)
            } else {
                // One-time recovery: wipe every pending/delivered notification
                // for this app and re-schedule from the current SwiftData
                // contact set. Cleans up orphans left by past builds whose
                // delete path targeted the wrong identifier.
                await NotificationHelper.performOneTimeNuclearReset(for: selectedContacts)
                hasPerformedNuclearNotificationReset = true
            }
        }
        timesUserHasLaunchedApp += 1
    }

    private func openContactPicker() {
        let picker = CNContactPickerViewController()
        picker.delegate = contactPicker

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            return
        }
        rootViewController.present(picker, animated: true)
    }

    @MainActor
    private func updateNextNotificationTime(for contacts: [SelectedContact]) {
        print("updating next notification time for all contacts")
        for contact in contacts {
            contact.next_notification_date_time = NotificationHelper.getNextNotificationDateFor(contact: contact)
        }
    }

    @MainActor
    private func saveSelectedContact(for contacts: [CNContact]) {
        for contact in contacts {
            let contactName = ContactHelper.getContactName(for: contact)
            guard !contactAlreadyAdded(name: contactName) else { continue }
            let selectedContact = ContactHelper.createSelectedContact(contact: contact)
            modelContext.insert(selectedContact)
        }
    }

    private func contactAlreadyAdded(name: String) -> Bool {
        selectedContacts.contains { $0.name == name }
    }

    private func removePendingNotificationsAndDeleteContact(at offsets: IndexSet) {
        let contactsToDelete = offsets.map { selectedContacts[$0] }
        Task { @MainActor in
            for contact in contactsToDelete {
                await NotificationHelper.removeExistingNotifications(for: contact)
                modelContext.delete(contact)
            }
        }
    }

    private func checkForUpdate() {
        let latestVersion = Utils.getCurrentAppVersion()
        print("latest version: \(latestVersion)")

        if savedVersion == latestVersion {
            print("App is up to date!")
        } else {
            if Utils.updateIsMajor() && timesUserHasLaunchedApp > 0 {
                // Toggle to show UpdatesScreen as a sheet
                print("Major update detected, showing UpdatesScreen...")
                isShowingUpdatesSheet = true
            }
            savedVersion = latestVersion
        }
    }
}

#Preview {
    HomeScreen()
}
