//
//  ContactInfoView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactInfoView: View {
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
        Converter.getTappablePhoneNumber(from: contact.email)
    }

    var tappableSecondaryEmail: URL {
        Converter.getTappablePhoneNumber(from: contact.secondary_email)
    }

    var body: some View {
        if ContactHelper.contactHasPhone(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Phone")
                    .font(.caption)

                Button(formattedPrimaryPhoneNumber) {
                    UIApplication.shared.open(tappablePrimaryPhoneNumber)
                }
                .foregroundColor(.blue)
            }
        }
        if ContactHelper.contactHasSecondaryPhone(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Phone")
                    .font(.caption)

                Button(formattedSecondaryPhoneNumber) {
                    UIApplication.shared.open(tappableSecondaryPhoneNumber)
                }
                .foregroundColor(.blue)
            }
        }
        if ContactHelper.contactHasEmail(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Email")
                    .font(.caption)

                Button(contact.email) {
                    UIApplication.shared.open(tappablePrimaryEmail)
                }
                .foregroundColor(.blue)
            }
        }
        if ContactHelper.contactHasSecondaryEmail(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Email")
                    .font(.caption)

                Button(contact.secondary_email) {
                    UIApplication.shared.open(tappableSecondaryEmail)
                }
                .foregroundColor(.blue)
            }
        }
        if ContactHelper.contactHasAddress(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Address")
                    .font(.caption)
                Text(contact.address)
            }
        }
        if ContactHelper.contactHasSecondaryAddress(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Secondary Address")
                    .font(.caption)
                Text(contact.secondary_address)
            }
        }
        if ContactHelper.contactHasBirthday(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Birthday")
                    .font(.caption)
                Text(Converter.getFormattedBirthdayOrAnniversary(from: contact.birthday))
            }
        }
        if ContactHelper.contactHasAnniversary(contact) {
            VStack(alignment: .leading, spacing: 3) {
                Text("Anniversary")
                    .font(.caption)
                Text(Converter.getFormattedBirthdayOrAnniversary(from: contact.anniversary))
            }
        }
    }
}

#Preview {
    ContactInfoView(contact: SelectedContact.sampleData)
}
