//
//  AddressInfoRow.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 5/19/26.
//  Copyright © 2026 Token Solutions. All rights reserved.
//

import MapKit
import SwiftUI

struct AddressInfoRow: View {
    let title: LocalizedStringKey
    let address: String

    @State private var isShowingGeocodingError = false
    @State private var geocodingErrorMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(title)
                .font(.caption)

            Button(address, action: openInMaps)
                .foregroundStyle(.blue)
        }
        .alert("Couldn't open in Maps", isPresented: $isShowingGeocodingError) {
        } message: {
            Text(geocodingErrorMessage)
        }
    }

    private func openInMaps() {
        Task {
            await openAddressInMaps(address: address)
        }
    }

    private func openAddressInMaps(address: String) async {
        guard let request = MKGeocodingRequest(addressString: address) else {
            presentError("That address couldn't be parsed.")
            return
        }
        do {
            let mapItems = try await request.mapItems
            guard let destination = mapItems.first else {
                presentError("No matching location was found.")
                return
            }
            MKMapItem.openMaps(with: [destination])
        } catch {
            presentError(error.localizedDescription)
        }
    }

    private func presentError(_ message: String) {
        geocodingErrorMessage = message
        isShowingGeocodingError = true
    }
}

#Preview {
    AddressInfoRow(title: "Address", address: "2190 E 11th Ave")
}
