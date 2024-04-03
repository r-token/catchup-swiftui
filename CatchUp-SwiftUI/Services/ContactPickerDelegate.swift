//
//  ContactPickerDelegate.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 3/10/24.
//  Copyright © 2024 Token Solutions. All rights reserved.
//

import ContactsUI
import SwiftUI

@Observable
class ContactPickerDelegate: NSObject, CNContactPickerDelegate {
    var chosenContacts = [CNContact]()

    func contactPicker(_ picker: CNContactPickerViewController, didSelect contacts: [CNContact]) {
        chosenContacts = contacts
        for contact in chosenContacts {
            print("selected contact: \(contact.givenName) \(contact.familyName)")
        }
    }
}
