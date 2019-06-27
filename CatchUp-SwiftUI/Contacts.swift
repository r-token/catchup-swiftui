//
//  ContactUtilities.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import SwiftUI
import Foundation
import Contacts
import ContactsUI

class Contacts: UIViewController, CNContactPickerDelegate {
    
    func verifyAccessToContactsDatabase() {
        let store = CNContactStore()
        
        switch CNContactStore.authorizationStatus(for: .contacts){
        case .authorized:
            print("Access acquired, continue")
            self.pickContacts()
        case .notDetermined:
            store.requestAccess(for: .contacts){succeeded, err in
                guard err == nil && succeeded else{
                    return
                }
                print("Requesting access...")
            }
        case .denied:
            let alert = UIAlertController(title: "Cannot Add Contacts", message: "🤭 You denied CatchUp access to your Contacts. To change this, go the Settings app, scroll down to CatchUp, and turn on Allow CatchUp to Access Contacts", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(alert, animated: true, completion: nil)
        default:
            print("Not handled")
        }
    }
    
    func pickContacts() {
        let contactPicker = CNContactPickerViewController()
        
        contactPicker.delegate = self
        
        //will only show the contact's first name (given name) and their phone number
        contactPicker.displayedPropertyKeys = [CNContactGivenNameKey, CNContactPhoneNumbersKey]
        
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPickerDidCancel(picker: CNContactPickerViewController) {
        print("Cancelled picking a contact")
    }
    
    func contactPicker(picker: CNContactPickerViewController,
                       didSelectContact contact: CNContact) {
        
        print("Selected a contact")
        
        if contact.isKeyAvailable(CNContactPhoneNumbersKey){
            //this is an extension I've written on CNContact
            print(contact.phoneNumbers)
        } else {
            /*
             TOOD: partially fetched, use what you've learnt in this chapter to
             fetch the rest of this contact
             */
            print("No phone numbers are available")
        }
        
    }
    
}
