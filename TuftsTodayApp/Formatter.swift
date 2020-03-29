//
//  DateFormatter.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 3/12/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import Foundation


class Formatter{
    
    class func dateFormatterToString(dateString: String, originalFormat: String, convertTo: String) -> String{
        //https://nsdateformatter.com/
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if originalFormat == "\(timeTypes.ymdZFormat)"{
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        } else {
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        }
        
        let date = dateFormatter.date(from: dateString)!
        let dateFormatterPrint = DateFormatter()
        if convertTo == "\(timeTypes.toTimeOfDay)"{
            dateFormatterPrint.dateFormat = "h:mm a"
            return dateFormatterPrint.string(from: date)
        } else if convertTo == "\(timeTypes.toDate)"{
            dateFormatterPrint.dateFormat = "EEEE, MMM d"
            return dateFormatterPrint.string(from: date)
        } else if convertTo == "\(timeTypes.toDateWithYear)"{
            dateFormatterPrint.dateFormat = "EEEE, MMM d, yyyy"
            return dateFormatterPrint.string(from: date)
        }
        return ""
    }
    
    class func dateFormatterToDate(dateString: String, originalFormat: String) -> Date{
        //https://nsdateformatter.com/
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        if originalFormat == "\(timeTypes.emdFormat)"{
            dateFormatter.dateFormat = "EEEE, MMM d, yyyy, h:mm a"
        }
        
        if let date = dateFormatter.date(from: dateString) {
            return date
        }
        return Date()
    }
    
}

enum timeTypes {
    case toTimeOfDay
    case toDate
    case toDateWithYear
    case ymdTFormat //"yyyy-MM-dd'T'HH:mm:ss"
    case ymdZFormat //"yyyy-MM-dd HH:mm:ss Z"
    case emdFormat //"EEEE, MMM d, yyyy"
}

//Convert html code to a regular string:
extension Data {
    var html2AttributedString: NSAttributedString? {
        do {
            return try NSAttributedString(data: self, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            print("error:", error)
            return  nil
        }
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}
