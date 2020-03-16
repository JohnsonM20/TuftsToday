//
//  DateFormatter.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 3/12/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import Foundation


class Formatter{
    
    class func dateFormatter(dateString: String, originalFormat: String, convertTo: String) -> String{
        //https://nsdateformatter.com/
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        if originalFormat == "\(timeTypes.ZFormat)"{
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
        }
        return ""
    }
    
}

enum timeTypes {
    case toTimeOfDay
    case toDate
    case TFormat
    case ZFormat
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
