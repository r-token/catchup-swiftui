//
//  ContentView.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 6/26/19.
//  Copyright © 2019 Token Solutions. All rights reserved.
//

import SwiftUI
import Contacts

struct Home : View {
	
	@Environment(\.managedObjectContext) var managedObjectContext
	
	@FetchRequest(entity: SelectedContact.entity(),
	sortDescriptors: [])
	
	var selectedContacts: FetchedResults<SelectedContact>
	
	@State private var showingContactPicker = false
	
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
		}
		
		// this causes a crash at the moment
//		do {
//			try managedObjectContext.save()
//		} catch {
//			print("Couldn't save after deleting the contact")
//		}
	}
	
    var body: some View {
        NavigationView {
            VStack {
                List {
					if selectedContacts.count > 0 {
						ForEach(selectedContacts) { contact in
							HStack {
								Image("DefaultPhoto")
									.resizable()
									.frame(width: 50, height: 50, alignment: .leading)
								
								VStack(alignment: .leading, spacing: 10) {
									Text(contact.name)
										.font(.headline)
									Text(contact.notification_preference)
										.font(.caption)
								}
							}
						}.onDelete(perform: deleteContact)
					} else {
						Text("")
					}
				}
                
                Button(action: {
					self.showingContactPicker = true
                }) {
                    Text("Add Contacts")
                        .font(.headline)
                        .padding()
                }
					
				Button("Print Selected Contacts") {
					self.printSelectedContacts()
				}
					
				.navigationBarTitle(Text("CatchUp"))
					.font(.largeTitle)
					.foregroundColor(.blue)
            }
			.sheet(isPresented: $showingContactPicker) {
				ContactPicker()
			}
        }
    }
}

#if DEBUG
struct Home_Previews : PreviewProvider {
    static var previews: some View {
		
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        return Home().environment(\.managedObjectContext, context)
    }
}
#endif

