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


class Response: Codable {
    
    var results = [Item]()
}

class Item: Codable, CustomStringConvertible {
    var description: String{
        return "title: \(title), dateTimeFormatted: \(dateTimeFormatted), location: \(location), startDateTime: \(startDateTime), endDateTime: \(endDateTime)"
    }
    
    var title: String
    //var description: String = ""
    var dateTimeFormatted: String
    var location: String
    var startDateTime: String
    var endDateTime: String
        /*
    var time: String
    var building: String
    var buildingRoom: String
    var campus: String
    var eventType: String
    var eventSponsorAndSponsor: String
    var eventContact: String
    var openToPublic: String
    var link: String
 */
}

class ChecklistViewController: UITableViewController {
    
    var itemList: [Item] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //http://www.trumba.com/calendars/tufts.json
        
        
        do{
            let urlString = String(format:"https://www.trumba.com/calendars/tufts.json")
            let url = URL(string: urlString)
            var content = try String(contentsOf: url!, encoding: .utf8)
            content = "{\"results\": " + content + "}"
            //print("modified:" + content)
            let json: Data? = content.data(using: .utf8)
            let decoder = JSONDecoder()
            let product = try decoder.decode(Response.self, from: json!)
            
            itemList = product.results
            
        } catch{
            print("error")
        }
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ChecklistItem", for: indexPath)
        
        let name = cell.viewWithTag(1) as! UILabel
        let info = cell.viewWithTag(2) as! UILabel

        name.text = itemList[indexPath.row].title
        info.text = itemList[indexPath.row].location
        //time.text = itemList[indexPath.row].startDateTime
        
 
        return cell
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return itemList.count
        
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

class listItem{
    //
    
    init(title: String, description: String, date: String, time: String, building: String, buildingRoom: String, campus: String, eventType: String, eventSponsorAndSponsor: String, eventContact: String, openToPublic: String, link: String){
    }
    
    var title = String()
    var description = String()
    //
    var date = String()
    var time = String()
    //
    var building = String()
    var buildingRoom = String()
    var campus = String()
    
    var eventType = String()
    var eventSponsorAndSponsor = String()
    var eventContact = String()
    //
    var openToPublic = String()
    var link = String()
}
