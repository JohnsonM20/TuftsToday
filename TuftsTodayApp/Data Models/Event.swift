//
//  Event.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/16/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import Foundation

class Event: EventRow{
    
    //var title: String
    var description: String = ""
    var location: String = ""
    var startDay: String = ""
    var endDay: String = ""
    var startTime: String = ""
    var endTime: String = ""
    var eventID: Int = 0
    var webLink: String = ""
    
    init(title: String, description: String, location: String, startDay: String, endDay: String, startTime: String, endTime: String, eventID: Int, webLink: String){
        super.init(title: title)
        self.description = description
        self.location = location
        self.startDay = startDay
        self.endDay = endDay
        self.startTime = startTime
        self.endTime = endTime
        self.eventID = eventID
        self.webLink = webLink
    }
    
}
