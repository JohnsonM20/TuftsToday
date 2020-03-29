//
//  EventViewController.swift
//  TuftsToday
//
//  Created by Matthew Johnson on 2/11/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import SwiftSoup
import Foundation

class EventViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, ViewEventDetailsViewControllerDelegate {
    func viewEventDetailsViewController(controller: ViewEventDetailsViewController) {
        navigationController?.popViewController(animated:true)
    }
    
    @IBOutlet weak var table: UITableView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var submitButton: UIBarButtonItem!
    @IBOutlet weak var todayButton: UIBarButtonItem!
    
    var eventList: [EventItemResponse] = []
    var eventAndDateList: [EventRow] = []
    
    var unofficialEventList: [EventRow] = []
    var isOfficialEvents = true
    lazy var rowsToDisplay = eventAndDateList
    
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    //MARK: fr
    override func viewDidLoad() {
        super.viewDidLoad()
        
        segmentControl.addTarget(self, action: #selector(handleSegmentChange), for: .valueChanged)
        eventList = appDelegate.itemList
        let todaysDate = Date()
        //print("Today's Date: \(todaysDate)")
        
        var index = 0
        for event in eventList{
            //print("Today's Starting Date: \(event.startDateTime)")
            let startDate = Formatter.dateFormatterToString(dateString: event.startDateTime, originalFormat: "\(timeTypes.ymdTFormat)", convertTo: "\(timeTypes.toDate)")
            let endDate = Formatter.dateFormatterToString(dateString: event.endDateTime, originalFormat: "\(timeTypes.ymdTFormat)", convertTo: "\(timeTypes.toDate)")
            let startTime = Formatter.dateFormatterToString(dateString: event.startDateTime, originalFormat: "\(timeTypes.ymdTFormat)", convertTo: "\(timeTypes.toTimeOfDay)")
            let endTime = Formatter.dateFormatterToString(dateString: event.endDateTime, originalFormat: "\(timeTypes.ymdTFormat)", convertTo: "\(timeTypes.toTimeOfDay)")
            
            let startDateWithYear = Formatter.dateFormatterToString(dateString: event.startDateTime, originalFormat: "\(timeTypes.ymdTFormat)", convertTo: "\(timeTypes.toDateWithYear)")
            let endDateWithYear = Formatter.dateFormatterToString(dateString: event.endDateTime, originalFormat: "\(timeTypes.ymdTFormat)", convertTo: "\(timeTypes.toDateWithYear)")
            
            if index == 0 || startDate != Formatter.dateFormatterToString(dateString: eventList[index-1].startDateTime, originalFormat: "\(timeTypes.ymdTFormat)", convertTo: "\(timeTypes.toDate)"){
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                let itemDate = dateFormatter.date(from: event.startDateTime)!
                if itemDate >= todaysDate{
                    let newEvent = EventRow(title: "\(startDate)")
                    eventAndDateList.append(newEvent)
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
            
            let newEvent = Event(title: event.title, description: event.desc, location: event.location, startDay: startDateWithYear, endDay: endDateWithYear, startTime: startTime, endTime: endTime, eventID: event.eventID, webLink: event.webLink)
            eventAndDateList.append(newEvent)
            
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
    
    @objc private func handleSegmentChange(){
        isOfficialEvents = !isOfficialEvents
        //print(segmentControl.selectedSegmentIndex)
        
        switch segmentControl.selectedSegmentIndex {
        case 0:
            rowsToDisplay = eventAndDateList
        case 1:
            rowsToDisplay = unofficialEventList
        default:
            rowsToDisplay = eventAndDateList
        }
        table.reloadData()
    }

    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        if let event = eventAndDateList[indexPath.row] as? Event{
            if isOfficialEvents == true{
                //print("item cell")
                let name = cell.viewWithTag(1) as! UILabel
                let info = cell.viewWithTag(2) as! UILabel
                //let check = cell.viewWithTag(1001) as! UILabel
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
                
            }
        } else if isOfficialEvents == true{
            //print("new day cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewDay", for: indexPath)
            let date = cell.viewWithTag(10) as! UILabel
            
            date.text = eventAndDateList[indexPath.row].title
            return cell
        } else {
            
        }

        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowsToDisplay.count
        
    }
    
    // MARK:- Table View Delegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            if eventAndDateList[indexPath.row] is Event{
                performSegue(withIdentifier: "ViewItem", sender: cell)
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func scrollToTop(_ sender: Any) {
        table.scrollToRow(at: IndexPath(row: 0, section: 0), at: UITableView.ScrollPosition.top, animated: true)
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
            controller.viewEventsDelegate = self
            if let indexPath = table.indexPath(for: sender as! UITableViewCell) {
                controller.itemViewed = eventAndDateList[indexPath.row] as? Event
            }
        }
    }
}
