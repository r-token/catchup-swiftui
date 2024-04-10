//
//  ContactInfoView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import MapKit
import SwiftUI

struct ContactInfoView: View {
    @State private var isShowingEmailAlert = false
    @State private var emailString = ""
    @State private var emailUrlForAlert: URL?

    let contact: SelectedContact

    var formattedPrimaryPhoneNumber: String {
        Converter.getFormattedPhoneNumber(from: contact.phone)
    }

    var formattedSecondaryPhoneNumber: String {
        Converter.getFormattedPhoneNumber(from: contact.secondary_phone)
    }

    var tappablePrimaryPhoneNumber: URL {
        Converter.getTappablePhoneNumber(from: contact.phone)
    }

    var tappableSecondaryPhoneNumber: URL {
        Converter.getTappablePhoneNumber(from: contact.secondary_phone)
    }

    var tappablePrimaryEmail: URL {
        Converter.getTappableEmail(from: contact.email)
    }

    var tappableSecondaryEmail: URL {
        Converter.getTappableEmail(from: contact.secondary_email)
    }

    var body: some View {
        if ContactHelper.contactHasPhone(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Phone")
                    .font(.caption)

                Button(formattedPrimaryPhoneNumber) {
                    UIApplication.shared.open(tappablePrimaryPhoneNumber)
                }
                .foregroundStyle(.blue)
            }
        }
        if ContactHelper.contactHasSecondaryPhone(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Phone")
                    .font(.caption)

                Button(formattedSecondaryPhoneNumber) {
                    UIApplication.shared.open(tappableSecondaryPhoneNumber)
                }
                .foregroundStyle(.blue)
            }
        }
        if ContactHelper.contactHasEmail(contact) {
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
        if ContactHelper.contactHasSecondaryEmail(contact) {
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
        if ContactHelper.contactHasAddress(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Address")
                    .font(.caption)
                Button(contact.address) {
                    openAddressInMaps(address: contact.address)
                }
                .foregroundStyle(.blue)
            }
        }
        if ContactHelper.contactHasSecondaryAddress(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Address")
                    .font(.caption)
                Button(contact.secondary_address) {
                    openAddressInMaps(address: contact.secondary_address)
                }
                .foregroundStyle(.blue)
            }
        }
        if ContactHelper.contactHasBirthday(contact) {
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
        if ContactHelper.contactHasAnniversary(contact) {
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
