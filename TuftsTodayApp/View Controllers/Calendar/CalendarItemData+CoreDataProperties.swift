//
//  CalendarItemData+CoreDataProperties.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 3/5/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//
//

import Foundation
import CoreData


extension CalendarItemData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CalendarItemData> {
        return NSFetchRequest<CalendarItemData>(entityName: "CalendarItemData")
    }

    @NSManaged public var date: Date?
    @NSManaged public var itemID: String
    @NSManaged public var name: String?
    @NSManaged public var shouldRemind: Bool

}
