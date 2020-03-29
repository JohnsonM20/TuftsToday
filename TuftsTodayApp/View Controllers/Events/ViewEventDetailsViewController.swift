//
//  ViewEventDetailsViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/17/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import SwiftSoup
import CoreData

protocol ViewEventDetailsViewControllerDelegate: class {
    func viewEventDetailsViewController(controller: ViewEventDetailsViewController)
}

protocol AddEventToCalendarVCDelegate: class {
    func addEventVC(_ controller: ViewEventDetailsViewController, didAdd name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String)
    func deleteEventVC(_ controller: ViewEventDetailsViewController, didDelete id: String)
}

class ViewEventDetailsViewController: UITableViewController {

    @IBOutlet weak var eventDetails: UITextView!
    @IBOutlet weak var calendarSwitch: UISwitch!
    weak var viewEventsDelegate: ViewEventDetailsViewControllerDelegate?
    weak var addToCalendarDelegate: AddEventToCalendarVCDelegate?
    var itemViewed: Event?
    var attributedString = NSMutableAttributedString(string:"", attributes:nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        if isItemInCalendar(){
            calendarSwitch.setOn(true, animated: false)
        } else {
            calendarSwitch.setOn(false, animated: false)
        }
        
        if let itemViewed = itemViewed  {
            title = "Event Details"
            addEventDetail(title: "Event", description: itemViewed.title.html2String)
            addEventDetail(title: "Description", description: itemViewed.description.html2String)
            addEventDetail(title: "Location", description: itemViewed.location.html2String)
            //addEventDetail(title: "Building", description: itemViewed..html2String)
            addEventDetail(title: "Day", description: "\(itemViewed.startDay)")
            
            var timeText = ""
            timeText = "\(itemViewed.startTime)"
            if itemViewed.startTime != itemViewed.endTime{
                timeText = timeText + " - " + "\(itemViewed.endTime)"
            }
            addEventDetail(title: "Time", description: timeText)
            do{
                let html = itemViewed.webLink
                if html != ""{
                    let doc: Document = try SwiftSoup.parse(html)
                    let p: Element = try doc.select("a").first()!
                    let link: String = try p.attr("href")
                    addEventDetail(title: "Website", description: link)
                }
            } catch{
                print("fail1")
            }
            eventDetails.attributedText = attributedString
        } else {
            print("fail2")
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
    }
    
    @IBAction func addToCalendar(_ addToCalendar: UISwitch) {
        addToCalendarDelegate = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Calendar") as! CalendarViewController
        
        if addToCalendar.isOn{
            let startDate = Formatter.dateFormatterToDate(dateString: "\(itemViewed!.startDay), \(itemViewed!.startTime)", originalFormat: "\(timeTypes.emdFormat)")
            let endDate = Formatter.dateFormatterToDate(dateString: "\(itemViewed!.endDay), \(itemViewed!.endTime)", originalFormat: "\(timeTypes.emdFormat)")
            
            let eventDescription = "\(itemViewed!.description.html2String) \n\n\(itemViewed!.location.html2String)"
            
            addToCalendarDelegate?.addEventVC(self, didAdd: itemViewed!.title, desc: eventDescription, date: startDate, endDate: endDate, remind: true, id: itemViewed!.eventID.description)
            
            if addToCalendarDelegate != nil{
            } else {
                print("error")
            }
        } else {
            addToCalendarDelegate?.deleteEventVC(self, didDelete: itemViewed!.eventID.description)
        }
    }
    
    func addEventDetail(title: String, description: String){
        let boldText = "\(title):\n"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 28)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        self.attributedString.append(attributedString)
        var normalText = description + "\n\n"
        if description == ""{
            normalText = "N/A\n\n"
        }
        let normalString = NSMutableAttributedString(string:normalText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)])
        if title == "Linkk"{
            //let length = self.attributedString.length+normalText.count
            //self.attributedString.addAttribute(.link, value: "", range: self.attributedString.length, length)
        } else {
            self.attributedString.append(normalString)
        }

    }
    
    func isItemInCalendar() -> Bool{
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false}
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CalendarItemData>(entityName: "CalendarItemData")
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results{
                if let resultID = result.value(forKey: "itemID") as? String{
                    if itemViewed?.eventID.description == resultID{
                        return true
                    }
                }
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        return false
    }
}
