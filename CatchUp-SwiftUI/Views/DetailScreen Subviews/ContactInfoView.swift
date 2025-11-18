//
//  ContactInfoView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import MapKit
import PhoneNumberKit
import SwiftUI

struct ContactInfoView: View {
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

    let phoneNumberKit = PhoneNumberUtility()
    let contact: SelectedContact

    var body: some View {
        if contact.hasPhone() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Phone")
                    .font(.caption)

                Button(formattedPrimaryPhoneNumber) {
                    if let tappablePrimaryPhoneNumber {
                        UIApplication.shared.open(tappablePrimaryPhoneNumber)
                    } else {
                        isShowingInvalidPhoneNumberAlert = true
                    }
                }
                .foregroundStyle(.blue)
            }
            .alert("Phone number is invalid", isPresented: $isShowingInvalidPhoneNumberAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("Could not dial this phone number. Ensure the number is correct in your Contacts app.")
            })
            .onAppear {
                formatContactInfo()
            }
            .onChange(of: contact.phone) { _, _ in formatContactInfo() }
            .onChange(of: contact.secondary_phone) { _, _ in formatContactInfo() }
            .onChange(of: contact.email) { _, _ in formatContactInfo() }
            .onChange(of: contact.secondary_email) { _, _ in formatContactInfo() }
        }

        if contact.hasSecondaryPhone() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Phone")
                    .font(.caption)

                Button(formattedSecondaryPhoneNumber) {
                    if let tappableSecondaryPhoneNumber {
                        UIApplication.shared.open(tappableSecondaryPhoneNumber)
                    } else {
                        isShowingInvalidPhoneNumberAlert = true
                    }
                }
                .foregroundStyle(.blue)
            }
        }

        if contact.hasEmail() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Email")
                    .font(.caption)

                Button(contact.email) {
                    emailString = contact.email
                    emailUrlForAlert = tappablePrimaryEmail
                    isShowingEmailAlert = true
                }
                .foregroundStyle(.blue)
            }

            .alert("Email \(emailString)?", isPresented: $isShowingEmailAlert) {
                if let emailUrlForAlert {
                    Button("Yes") {
                        UIApplication.shared.open(emailUrlForAlert)
                    }
                }

                Button("Cancel", role: .cancel) {}
            }
        }

        if contact.hasSecondaryEmail() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Email")
                    .font(.caption)

                Button(contact.secondary_email) {
                    emailString = contact.secondary_email
                    emailUrlForAlert = tappableSecondaryEmail
                    isShowingEmailAlert = true
                }
                .foregroundStyle(.blue)
            }
        }

        if contact.hasAddress() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Address")
                    .font(.caption)
                Button(contact.address) {
                    openAddressInMaps(address: contact.address)
                }
                .foregroundStyle(.blue)
            }
        }

        if contact.hasSecondaryAddress() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Address")
                    .font(.caption)
                Button(contact.secondary_address) {
                    openAddressInMaps(address: contact.secondary_address)
                }
                .foregroundStyle(.blue)
            }
        }

        if contact.hasBirthday() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Birthday")
                    .font(.caption)
                Text(Converter.getFormattedBirthdayOrAnniversary(from: contact.birthday))
                if !contact.preferenceIsNever() {
                    Text("🥳 We will notify you on their birthday")
                        .foregroundStyle(.orange)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                        .padding(.top, 3)
                }
            }
        }
        
        if contact.hasAnniversary() {
            VStack(alignment: .leading, spacing: 3) {
                Text("Anniversary")
                    .font(.caption)
                Text(Converter.getFormattedBirthdayOrAnniversary(from: contact.anniversary))
                if !contact.preferenceIsNever() {
                    Text("💜 We will notify you the day before their anniversary")
                        .foregroundStyle(.purple)
                        .multilineTextAlignment(.leading)
                        .font(.callout)
                        .padding(.top, 3)
                }
            }
        }
    }

    private func formatContactInfo() {
        // Only format non-empty fields to avoid unnecessary parsing errors
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

    func openAddressInMaps(address: String){
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            guard let placemarks = placemarks?.first else {
                return
            }

            let location = placemarks.location?.coordinate

            if let lat = location?.latitude, let long = location?.longitude{
                let destination = MKMapItem(placemark: MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: long)))
                destination.name = address

                MKMapItem.openMaps(
                    with: [destination]
                )
            }
        }
    }
}

#Preview {
    ContactInfoView(contact: SelectedContact.sampleData)
}
