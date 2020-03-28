//
//  AppDelegate.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/11/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import UserNotifications
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    public var itemList: [EventItemResponse] = []

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        let eventVC = EventViewController()
        self.itemList = eventVC.getEventsFromSite()
        
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
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
    
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "TuftsToday")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func printData(){
        //Prints out all of the data currently in Calendar view
        let managedContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "CalendarItemData")
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results{
                if let name = result.value(forKey: "name") as? String{
                    print("Got device named " + name)
                }
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
    }
    
    func testNotofication(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) {
          granted, error in
          if granted {
            print("We have permission")

          } else {
            print("Permission denied")
          }
        }

        let content = UNMutableNotificationContent()
        content.title = "Hello!"
        content.body = "I am a local notification"
        content.sound = UNNotificationSound.default
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        let request = UNNotificationRequest(identifier: "MyNotification", content: content,
        trigger: trigger)
        center.add(request)
    }


}
//http://dyang108.github.io/projects/2016/03/21/tufts-dining-api
//https://appicon.co
/*
//TODO:
 Event descriptions for calendar
 Star events to add to calendar
 Search for events in list
 
 Display meals
 Events tab for student hosted events
 Reddit like functionality for discussions
 ClassChat - Allows for chat for students in your class
 Find Friends section - 'looking for someone for gym partner, driving carpool'
 Washing Availability
 
 
 It can be a bit confusing to look at, but that's a single week. It's organized in two (or more) columns per day because you can have different blocks going at the same time.

 So for example, you might take Calc 1 Block D+ on Monday/Wednesday, French Block B Tuesday/Thursday/Friday, Physics block N+ Tuesday/Thursday, with a Lab section Monday during block 10, and History block H+ on Tuesday/Thursday.

 The numbered blocks are generally labs or recitations, while the lettered blocks are your base classes
 
 */
