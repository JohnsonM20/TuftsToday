//
//  CalendarItemData+CoreDataClass.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 3/5/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//
//

import Foundation
import CoreData
import UserNotifications

@objc(CalendarItemData)
public class CalendarItemData: NSManagedObject {
    
    deinit {
      removeNotification()
    }
    
    func scheduleNotification() { // for 10 mintues before
        removeNotification()
        if shouldRemind && startDate >= Date() {
            let content = UNMutableNotificationContent()
            
            content.title = "Reminder:"
            content.body = name + " in 10 minutes"
            content.sound = UNNotificationSound.default
            
            //does not deal with notifications scheduled within next 10 minutes
            let calendar = Calendar(identifier: .gregorian)
            let notificationTime = startDate.addingTimeInterval(-(60*10))
            let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: notificationTime)
            let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
            let request = UNNotificationRequest(identifier: "\(itemID)", content: content, trigger: trigger)
            let center = UNUserNotificationCenter.current()
            
            center.add(request)
            //print("Scheduled: \(request) for itemID: \(itemID)")
        }
    }
    
    func removeNotification() {
        let center = UNUserNotificationCenter.current()
        center.removePendingNotificationRequests(withIdentifiers: ["\(itemID)"])
    }
}
