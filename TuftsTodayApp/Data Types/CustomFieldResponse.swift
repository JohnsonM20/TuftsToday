//
//  customFieldResponse.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/20/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import Foundation

class CustomFieldResponse: Codable, CustomStringConvertible {
    var description: String{
        return "fieldID: \(fieldID), label: \(label), value: \(value)"
    }
    
    var fieldID: Int
    var label: String
    var value: String
}
