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

enum ActiveSheet {
	case contactPicker, about
}

struct HomeScreen : View {
	@State private var showSheet = false
	@State private var activeSheet: ActiveSheet = .contactPicker
	@Environment(\.managedObjectContext) var managedObjectContext
	@FetchRequest(entity: SelectedContact.entity(),
				  sortDescriptors: []) var selectedContacts: FetchedResults<SelectedContact>
	
	let converter = Conversions()
	
	init() {
        //Use this if NavigationBarTitle is with Large Font
		UINavigationBar.appearance().largeTitleTextAttributes = [.foregroundColor: UIColor.systemOrange]
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
								
								VStack(alignment: .leading, spacing: 2) {
									Text(contact.name)
										.font(.headline)
									Text(self.converter.convertNotificationPreferenceIntToString(preference: Int(contact.notification_preference), contact: contact))
										.font(.caption)
										.foregroundColor(.gray)
								}
							}
						}
					}.onDelete(perform: deleteContact)
				}
                
                Button(action: {
					self.showSheet = true
					self.activeSheet = .contactPicker
                }) {
					HStack(alignment: .center, spacing: 6) {
						Image(systemName: "person.crop.circle.fill.badge.plus")
						
						Text("Add Contacts")
					}
					.font(.headline)
					.foregroundColor(.blue)
					.padding(.top)
					.padding(.bottom)
                }
					
				.navigationBarTitle(Text("CatchUp"))
					
				.navigationBarItems(trailing:
					Button(action: {
						self.showSheet = true
						self.activeSheet = .about
					}) {
						Image(systemName: "ellipsis.circle")
							.font(.title)
							.foregroundColor(.blue)
					}
				)
            }
				
			.sheet(isPresented: $showSheet) {
				if self.activeSheet == .contactPicker {
					ContactPicker()
				} else {
					AboutScreen()
				}
			}
		}
		.accentColor(.orange)
		.onAppear(perform: clearBadgeAndSaveMOC)
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
			
			UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [contact.notification_identifier.uuidString, contact.birthday_notification_id.uuidString, contact.anniversary_notification_id.uuidString])
			
			managedObjectContext.delete(contact)
			print("Deleted contact and removed all notifications associated with them")
		}
	}
	
	func getContactPicture(from string: String) -> Image {
		let imageData = NSData(base64Encoded: string)
		let uiImage = UIImage(data: imageData! as Data)!
		let image = Image(uiImage: uiImage)
		
		return image
	}

	func clearBadgeAndSaveMOC() {
		UIApplication.shared.applicationIconBadgeNumber = 0
		
		do {
			try self.managedObjectContext.save()
		} catch {
			print("Couldn't save after deleting the contact")
		}
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

