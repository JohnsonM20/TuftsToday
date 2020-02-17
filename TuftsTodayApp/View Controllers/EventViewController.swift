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

class EventViewController: UITableViewController {
    //only has events
    var eventList: [EventItemResponse] = []
    
    //new list of all rows
    var eventAndDateList: [EventRow] = []
    
    var checkedItems: Set<Int> = []
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    let defaults = UserDefaults.standard
    var uniqueDays = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        eventList = appDelegate.itemList
        //print(eventList)
        
        if let stringOne = defaults.string(forKey: defaultKeys.checkedItems) {
            //print(stringOne)
            //checkedItems = (stringOne)
        } else {
            //print("erhehehe")
        }
        
        var index = 0
        for event in eventList{
            
            let startDate = dateFormatter(dateString: event.startDateTime, convertTo: "\(timeTypes.toDate)")
            let startTime = dateFormatter(dateString: event.startDateTime, convertTo: "\(timeTypes.toTimeOfDay)")
            let endTime = dateFormatter(dateString: event.endDateTime, convertTo: "\(timeTypes.toTimeOfDay)")
            
            if index == 0{
                let newEvent = EventRow(title: startDate)
                eventAndDateList.append(newEvent)
            } else if startTime != dateFormatter(dateString: eventList[index-1].startDateTime, convertTo: "\(timeTypes.toTimeOfDay)"){
                    
                let newEvent = EventRow(title: startDate)
                eventAndDateList.append(newEvent)
            }
            
            let newEvent = Event(title: event.title, description: event.desc, location: event.location, startDay: startDate, startTime: startTime, endTime: endTime, eventID: event.eventID)
            eventAndDateList.append(newEvent)
            
            uniqueDays += 1
            index += 1
        }
        
        //print(eventAndDateList)
        print("Unique Days: \(uniqueDays)")
        print("Number of Events: \(eventList.count)")
        print(eventAndDateList.count)
        
        ///use this code to change the appearence of checkmark later
        //let checkImage = UIImage(named: "checkmark.png")
        //let checkmark = UIImageView(image: checkImage)
        //cell.accessoryView = checkmark
        
        // Uncomment the following line to preserve selection between presentations
        //self.clearsSelectionOnViewWillAppear = false

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
        //unique days used for finding total row numbers
        //to check which cell to use,

        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        if let event = eventAndDateList[indexPath.row] as? Event  {
            //print("item cell")
            let name = cell.viewWithTag(1) as! UILabel
            let info = cell.viewWithTag(2) as! UILabel
            let check = cell.viewWithTag(1001) as! UILabel
            
            //let rowNumber = indexPath.row//-uniqueDaysSoFar
            //eventList[rowNumber].addedRows = uniqueDaysSoFar
            //print(eventList[rowNumber].addedRows)
            
            let startingTime = event.startTime
            let endingTime = event.endTime
            
            name.text = event.title.html2String
            info.text = startingTime.html2String
            if startingTime != endingTime{
                info.text = info.text! + " - " + endingTime.html2String
            }
            if event.location != ""{
                info.text = info.text! + " | " + event.location.html2String
            }
            
            if checkedItems.contains(event.eventID){
                //cell.accessoryType = .checkmark
                check.text = "√"
            } else {
                //cell.accessoryType = .none
                check.text = ""
            }
        } else {
        //print("new day cell")
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewDay", for: indexPath)
            //cell.selectionStyle = .none;
            
            let date = cell.viewWithTag(10) as! UILabel
            date.text = eventAndDateList[indexPath.row].title
            return cell
        }

        return cell
        //}
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eventAndDateList.count
        
    }
    
    // MARK:- Table View Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath){
            
            if let event = eventAndDateList[indexPath.row] as? Event  {
                /*
                let check = cell.viewWithTag(1001) as! UILabel
                
                if checkedItems.contains(event.eventID) && cell.selectionStyle != .none{
                    //print("unchecked!")
                    //cell.accessoryType = .none
                    check.text = ""
                    checkedItems.remove(event.eventID)
                } else if cell.selectionStyle != .none{
                    //cell.accessoryType = .checkmark
                    //print("checked!")
                    checkedItems.insert(event.eventID)
                    check.text = "√"
                }
                */
                
                configureCheckmark(for: cell, with: event)
            }

        }
        //defaults.set(checkedItems, forKey: defaultKeys.checkedItems)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func configureCheckmark(for cell: UITableViewCell, with item: Event) {
        let label = cell.viewWithTag(1001) as! UILabel
        if checkedItems.contains(item.eventID){
            //cell.accessoryType = .checkmark
            label.text = ""
            checkedItems.remove(item.eventID)
        } else {
            //cell.accessoryType = .none
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

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


}



//You can add this extension to convert your html code to a regular string:
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

//You can add this extension to convert your html code to a regular string:
extension String {
    var html2AttributedString: NSAttributedString? {
        return Data(utf8).html2AttributedString
    }
    var html2String: String {
        return html2AttributedString?.string ?? ""
    }
}

struct defaultKeys {
    static let checkedItems = "checkedItemsKey"
}

enum timeTypes {
    case toTimeOfDay
    case toDate
}
