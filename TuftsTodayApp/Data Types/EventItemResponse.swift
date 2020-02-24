//
//  Item.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/16/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import Foundation

class EventItemResponse: Codable, CustomStringConvertible {
    var description: String{
        //return "title: \(title), dateTimeFormatted: \(dateTimeFormatted), location: \(location), startDateTime: \(startDateTime), endDateTime: \(endDateTime), desc: \(desc), eventID: \(eventID), webLink: \(webLink), customFields: \(customFields)"
        return "title: \(title), dateTimeFormatted: \(dateTimeFormatted), location: \(location), startDateTime: \(startDateTime), endDateTime: \(endDateTime), desc: \(desc), eventID: \(eventID), webLink: \(webLink)"
    }
    
    var title: String
    var desc: String
    var dateTimeFormatted: String
    var location: String
    var startDateTime: String
    var endDateTime: String
    var eventID: Int
    var webLink: String
    
    //var customFields = [CustomFieldResponse]()

}
