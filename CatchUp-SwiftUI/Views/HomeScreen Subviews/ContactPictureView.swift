//
//  ContactPictureView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/24/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import SwiftUI

struct ContactPictureView: View {
    let contact: SelectedContact

    var body: some View {
        Converter.getContactPicture(from: contact.picture)
            .renderingMode(.original)
            .resizable()
            .frame(width: 45, height: 45, alignment: .leading)
            .clipShape(Circle())
    }
}

#Preview {
    ContactPictureView(contact: SelectedContact.sampleData)
}
