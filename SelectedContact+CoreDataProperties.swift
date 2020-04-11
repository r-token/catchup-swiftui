//
//  SelectedContact+CoreDataProperties.swift
//  CatchUp-SwiftUI
//
//  Created by Ryan Token on 4/11/20.
//  Copyright © 2020 Token Solutions. All rights reserved.
//
//

import Foundation
import CoreData


extension SelectedContact: Identifiable {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SelectedContact> {
        return NSFetchRequest<SelectedContact>(entityName: "SelectedContact")
    }

    @NSManaged public var phone: String
    @NSManaged public var email: String
    @NSManaged public var secondary_email: String
    @NSManaged public var address: String
    @NSManaged public var secondary_address: String
    @NSManaged public var birthday: String
    @NSManaged public var anniversary: String
    @NSManaged public var name: String
    @NSManaged public var notification_preference: String
    @NSManaged public var secondary_phone: String
    @NSManaged public var picture: String
    @NSManaged public var id: UUID

}
