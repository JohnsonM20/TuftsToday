//
//  ChecklistViewController.swift
//  TuftsToday
//
//  Created by Matthew Johnson on 2/11/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import SwiftSoup
import Foundation

class EventViewController: UITableViewController, ViewEventDetailsViewControllerDelegate {
    func viewEventDetailsViewController(controller: ViewEventDetailsViewController) {
        navigationController?.popViewController(animated:true)
    }
    
    var eventList: [EventItemResponse] = []
    var eventAndDateList: [EventRow] = []
    var checkedItems: Set<Int> = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var uniqueDays = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        eventList = appDelegate.itemList
        let todaysDate = Date()
        //print("Today's Date: \(todaysDate)")
        
        var index = 0
        for event in eventList{
            //print("Today's Starting Date: \(event.startDateTime)")
            let startDate = dateFormatter(dateString: event.startDateTime, convertTo: "\(timeTypes.toDate)")
            let endDate = dateFormatter(dateString: event.endDateTime, convertTo: "\(timeTypes.toDate)")
            let startTime = dateFormatter(dateString: event.startDateTime, convertTo: "\(timeTypes.toTimeOfDay)")
            let endTime = dateFormatter(dateString: event.endDateTime, convertTo: "\(timeTypes.toTimeOfDay)")
            
            if index == 0 || startDate != dateFormatter(dateString: eventList[index-1].startDateTime, convertTo: "\(timeTypes.toDate)"){
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let itemDate = dateFormatter.date(from: event.startDateTime)!
                if itemDate >= todaysDate{
                    //if startDate != endDate{
                    //    let newEvent = EventRow(title: "\(startDate) - \(endDate)")
                    //    eventAndDateList.append(newEvent)
                    //} else {
                        let newEvent = EventRow(title: "\(startDate)")
                        eventAndDateList.append(newEvent)
                    //}
                    
                } else {
                    if startDate != endDate{
                        let newEvent = EventRow(title: "\(startDate) - \(endDate)")
                        eventAndDateList.append(newEvent)
                    } else {
                        let newEvent = EventRow(title: "\(startDate)")
                        eventAndDateList.append(newEvent)
                    }
                }
            }
            
            let newEvent = Event(title: event.title, description: event.desc, location: event.location, startDay: startDate, startTime: startTime, endTime: endTime, eventID: event.eventID, webLink: event.webLink)
            eventAndDateList.append(newEvent)
            
            uniqueDays += 1
            index += 1
        }
        
        ///use this code to change the appearence of checkmark later
        //let checkImage = UIImage(named: "checkmark.png")
        //let checkmark = UIImageView(image: checkImage)
        //cell.accessoryView = checkmark
    }
    
    func getEventsFromSite() -> [EventItemResponse]{
        do{
            let urlString = String(format:"https://www.trumba.com/calendars/tufts.json")
            let url = URL(string: urlString)
            var content = try String(contentsOf: url!, encoding: .utf8)
            content = "{\"results\": " + content + "}"
            content = content.replacingOccurrences(of: "description", with: "desc")
            //print("modified:" + content)
            let json: Data? = content.data(using: .utf8)
            let decoder = JSONDecoder()
            let product = try decoder.decode(EventsResponse.self, from: json!)
            
            eventList = product.results
            
        } catch{
            print("error")
        }
        return eventList
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func dateFormatter(dateString: String, convertTo: String) -> String{
        //https://nsdateformatter.com/
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
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

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        if let event = eventAndDateList[indexPath.row] as? Event  {
            //print("item cell")
            let name = cell.viewWithTag(1) as! UILabel
            let info = cell.viewWithTag(2) as! UILabel
            let check = cell.viewWithTag(1001) as! UILabel
            let startingTime = event.startTime
            let endingTime = event.endTime
            
            name.text = event.title.html2String
            info.text = startingTime.html2String
            if startingTime != endingTime{
                info.text = info.text! + " - " + "\(endingTime)"
            }
            if event.location != ""{
                info.text = info.text! + " | " + event.location.html2String
            }
            
            if checkedItems.contains(event.eventID){
                check.text = "√"
            } else {
                check.text = ""
            }
        } else {
            //print("new day cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewDay", for: indexPath)
            let date = cell.viewWithTag(10) as! UILabel
            
            date.text = eventAndDateList[indexPath.row].title
            return cell
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventAndDateList.count
        
    }
    
    // MARK:- Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            
            if let event = eventAndDateList[indexPath.row] as? Event  {
                configureCheckmark(for: cell, with: event)
            }

        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: Event) {
        let label = cell.viewWithTag(1001) as! UILabel
        if checkedItems.contains(item.eventID){
            label.text = ""
            checkedItems.remove(item.eventID)
        } else {
            label.text = "√"
            checkedItems.insert(item.eventID)
        }
    }
    
    @IBAction func scrollToTop(_ sender: Any) {
        self.tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
    }
    
    @IBAction func addEvent(_ sender: Any) {
        
        let alert = UIAlertController(title: "This will take you to the Tufts website. Do you want to continue?", message: "", preferredStyle: .alert)

        alert.addAction(UIAlertAction(title: "Yes", style: .default, handler: { _ in
            if let url = URL(string: "https://events.tufts.edu/submit/") {
                UIApplication.shared.open(url)
            }
        }))
        alert.addAction(UIAlertAction(title: "No", style: .cancel, handler: nil))

        self.present(alert, animated: true)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ViewItem" {
            let controller = segue.destination as! ViewEventDetailsViewController
            controller.delegate = self// as? ViewEventDetailsViewControllerDelegate
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemViewed = eventAndDateList[indexPath.row] as? Event
            }
        }
    }
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

enum timeTypes {
    case toTimeOfDay
    case toDate
}
