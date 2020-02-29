//
//  AppDelegate.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/11/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    public var itemList: [EventItemResponse] = []
    //var checkedItems: [String] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let eventVC = EventViewController()
        self.itemList = eventVC.getEventsFromSite()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
//
//        center.requestAuthorization(options: [.alert, .sound]) {
//          granted, error in
//          if granted {
//            print("We have permission")
//
//          } else {
//            print("Permission denied")
//          }
//        }
//
//        let content = UNMutableNotificationContent()
//        content.title = "Hello!"
//        content.body = "I am a local notification"
//        content.sound = UNNotificationSound.default
//        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
//        let request = UNNotificationRequest(identifier: "MyNotification", content: content,
//        trigger: trigger)
//        center.add(request)
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
    
    // MARK:- User Notification Delegates
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Received local notification \(notification)")
    }


}
//http://dyang108.github.io/projects/2016/03/21/tufts-dining-api
//https://resizeappicon.com/
/*
//TODO:
 Search for events in list
 Add checked events to calendar
 Save calendar events across runs
 Display meals
 Events tab for student hosted events
 Reddit like functionality for discussions
 Find Friends section - 'looking for someone for gym partner, driving carpool'
 Washing Availability
 
 */

/*
 
 It can be a bit confusing to look at, but that's a single week. It's organized in two (or more) columns per day because you can have different blocks going at the same time.

 So for example, you might take Calc 1 Block D+ on Monday/Wednesday, French Block B Tuesday/Thursday/Friday, Physics block N+ Tuesday/Thursday, with a Lab section Monday during block 10, and History block H+ on Tuesday/Thursday.

 The numbered blocks are generally labs or recitations, while the lettered blocks are your base classes
 
 */
//460
