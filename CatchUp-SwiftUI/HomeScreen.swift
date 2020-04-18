//
//  ContentView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import SwiftUI
import Contacts
import UserNotifications

struct HomeScreen : View {
	@State private var showingContactPicker = false
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: SelectedContact.entity(),
				  sortDescriptors: []) var selectedContacts: FetchedResults<SelectedContact>
	
	let converter = Conversions()
	
	init() {
        //Use this if NavigationBarTitle is with Large Font
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemOrange]
    }
	
	func printSelectedContacts() {
		print("total saved contacts: \(selectedContacts.count)")
		let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
		print("path to sqlite db: \(paths[0])")
		
		for contact in selectedContacts {
			print (contact.name)
		}
	}
	
	func deleteContact(at offsets: IndexSet) {
		for index in offsets {
			let contact = selectedContacts[index]
			managedObjectContext.delete(contact)
			
			UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.notification_identifier.uuidString, contact.birthday_notification_id.uuidString, contact.anniversary_notification_id.uuidString])
			
			print("Deleted \(contact.name) and removed all notifications associated with them")
		}
		
		// this causes a crash at the moment
//		do {
//			try managedObjectContext.save()
//		} catch {
//			print("Couldn't save after deleting the contact")
//		}
	}
	
	func getContactPicture(from string: String) -> Image {
		let imageData = NSData(base64Encoded: string)
		let uiImage = UIImage(data: imageData! as Data)!
		let image = Image(uiImage: uiImage)
		
		return image
	}
	
    var body: some View {
        NavigationView {
            VStack {
                List {
					ForEach(selectedContacts) { contact in
						NavigationLink(destination: DetailScreen(contact: contact)) {
							HStack {
								self.getContactPicture(from: contact.picture)
									.renderingMode(.original)
									.resizable()
									.frame(width: 45, height: 45, alignment: .leading)
									.clipShape(Circle())
								
								VStack(alignment: .leading, spacing: 10) {
									Text(contact.name)
										.font(.headline)
									Text(self.converter.convertNotificationPreferenceIntToString(preference: Int(contact.notification_preference)))
										.font(.caption)
								}
							}
						}
					}.onDelete(perform: deleteContact)
				}
                
                Button(action: {
					self.showingContactPicker = true
                }) {
                    Text("Add Contacts")
                        .font(.headline)
						.foregroundColor(.blue)
                        .padding()
                }
					
				.navigationBarTitle(Text("CatchUp"))
            }
			.sheet(isPresented: $showingContactPicker) {
				ContactPicker()
			}
		}
		.accentColor(.orange)
		.onAppear(perform: printSelectedContacts)
    }
}

#if DEBUG
struct HomeScreen_Previews : PreviewProvider {
    static var previews: some View {
		
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return HomeScreen().environment(\.managedObjectContext, context)
    }
}
#endif

