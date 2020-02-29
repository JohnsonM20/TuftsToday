//
//  EventsResponse.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/16/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import Foundation

class EventsResponse: Codable {
    
    var results = [EventItemResponse]()
}
