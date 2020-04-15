//
//  ContactPicker.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//

import SwiftUI
import Contacts

struct ContactPicker: UIViewControllerRepresentable {
    typealias UIViewControllerType = ContactPickerViewController

    final class Coordinator: NSObject, ContactPickerViewControllerDelegate {
        func ContactPickerViewController(_ viewController: ContactPickerViewController, didSelect contacts: [CNContact]) {
            // do nothing for now
        }

		// runs whether the user taps 'Done' or swipes down to get out of the contact picker
        func ContactPickerViewControllerDidCancel(_ viewController: ContactPickerViewController) {
            print("Canceled. Inside ContactPickerViewControllerDidCancel")
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }

    func makeUIViewController(context: UIViewControllerRepresentableContext<ContactPicker>) -> ContactPicker.UIViewControllerType {
        let result = ContactPicker.UIViewControllerType()
        result.delegate = context.coordinator
        return result
    }

    func updateUIViewController(_ uiViewController: ContactPicker.UIViewControllerType, context: UIViewControllerRepresentableContext<ContactPicker>) {
		
	}

}
