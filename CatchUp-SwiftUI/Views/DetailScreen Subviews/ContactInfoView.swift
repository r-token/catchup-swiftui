//
//  ContactInfoView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import PhoneNumberKit
import SwiftUI

struct ContactInfoView: View {
    @Environment(\.openURL) private var openURL

    let contact: SelectedContact

    @State private var isShowingEmailAlert = false
    @State private var emailString = ""
    @State private var emailUrlForAlert: URL?
    @State private var isShowingInvalidPhoneNumberAlert = false

    @State private var formattedPrimaryPhoneNumber = ""
    @State private var formattedSecondaryPhoneNumber = ""
    @State private var tappablePrimaryPhoneNumber: URL?
    @State private var tappableSecondaryPhoneNumber: URL?
    @State private var tappablePrimaryEmail: URL?
    @State private var tappableSecondaryEmail: URL?

    private let phoneNumberKit = PhoneNumberUtility()

    var body: some View {
        Group {
            if contact.hasPhone() {
                PhoneInfoRow(
                    title: "Phone",
                    formattedNumber: formattedPrimaryPhoneNumber,
                    tappableNumber: tappablePrimaryPhoneNumber,
                    isShowingInvalidPhoneAlert: $isShowingInvalidPhoneNumberAlert
                )
            }

            if contact.hasSecondaryPhone() {
                PhoneInfoRow(
                    title: "Secondary Phone",
                    formattedNumber: formattedSecondaryPhoneNumber,
                    tappableNumber: tappableSecondaryPhoneNumber,
                    isShowingInvalidPhoneAlert: $isShowingInvalidPhoneNumberAlert
                )
            }

            if contact.hasEmail() {
                EmailInfoRow(title: "Email", email: contact.email) {
                    presentEmailAlert(for: contact.email, url: tappablePrimaryEmail)
                }
            }

            if contact.hasSecondaryEmail() {
                EmailInfoRow(title: "Secondary Email", email: contact.secondary_email) {
                    presentEmailAlert(for: contact.secondary_email, url: tappableSecondaryEmail)
                }
            }

            if contact.hasAddress() {
                AddressInfoRow(title: "Address", address: contact.address)
            }

            if contact.hasSecondaryAddress() {
                AddressInfoRow(title: "Secondary Address", address: contact.secondary_address)
            }

            if contact.hasBirthday() {
                BirthdayInfoRow(contact: contact)
            }

            if contact.hasAnniversary() {
                AnniversaryInfoRow(contact: contact)
            }
        }
        .alert("Phone number is invalid", isPresented: $isShowingInvalidPhoneNumberAlert) {
        } message: {
            Text("Could not dial this phone number. Ensure the number is correct in your Contacts app.")
        }
        .alert("Email \(emailString)?", isPresented: $isShowingEmailAlert) {
            if let emailUrlForAlert {
                Button("Yes") {
                    openURL(emailUrlForAlert)
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .task(id: contactInfoSignature) {
            formatContactInfo()
        }
    }

    private var contactInfoSignature: String {
        "\(contact.phone)|\(contact.secondary_phone)|\(contact.email)|\(contact.secondary_email)"
    }

    private func presentEmailAlert(for email: String, url: URL?) {
        emailString = email
        emailUrlForAlert = url
        isShowingEmailAlert = true
    }

    private func formatContactInfo() {
        if contact.hasPhone() {
            formattedPrimaryPhoneNumber = Converter.getFormattedPhoneNumber(from: contact.phone, with: phoneNumberKit)
            tappablePrimaryPhoneNumber = Converter.getTappablePhoneNumber(from: contact.phone)
        }

        if contact.hasSecondaryPhone() {
            formattedSecondaryPhoneNumber = Converter.getFormattedPhoneNumber(from: contact.secondary_phone, with: phoneNumberKit)
            tappableSecondaryPhoneNumber = Converter.getTappablePhoneNumber(from: contact.secondary_phone)
        }

        if contact.hasEmail() {
            tappablePrimaryEmail = Converter.getTappableEmail(from: contact.email)
        }

        if contact.hasSecondaryEmail() {
            tappableSecondaryEmail = Converter.getTappableEmail(from: contact.secondary_email)
        }
    }
}

#Preview {
    ContactInfoView(contact: .sampleData)
}
