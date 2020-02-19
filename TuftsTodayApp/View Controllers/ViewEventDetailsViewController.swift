//
//  ViewEventDetailsViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/17/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import SwiftSoup

protocol ViewEventDetailsViewControllerDelegate: class {
    //func addItemViewControllerDidCancel(controller: AddItemViewController)
    func viewEventDetailsViewController(controller: ViewEventDetailsViewController)
    //func viewEventDetailsViewController(_ controller: AddItemViewController, didFinishEditing item: ChecklistItem)
}

class ViewEventDetailsViewController: UITableViewController {

    @IBOutlet weak var eventDetails: UITextView!
    weak var delegate: ViewEventDetailsViewControllerDelegate?
    //@IBOutlet weak var doneBarButton: UIBarButtonItem!
    var itemViewed: Event?
    var attributedString = NSMutableAttributedString(string:"", attributes:nil)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        //eventDetails.translatesAutoresizingMaskIntoConstraints = true
        //eventDetails.sizeToFit()
        
        
        if let itemViewed = itemViewed  {
            title = "Event Details"
            addEventDetail(title: "Event", description: itemViewed.title.html2String)
            addEventDetail(title: "Description", description: itemViewed.description.html2String)
            addEventDetail(title: "Location", description: itemViewed.location.html2String)
            //addEventDetail(title: "Building", description: itemViewed..html2String)
            addEventDetail(title: "Day", description: itemViewed.startDay.html2String)
            
            var timeText = ""
            timeText = itemViewed.startTime.html2String
            if itemViewed.startTime != itemViewed.endTime{
                timeText = timeText + " - " + itemViewed.endTime.html2String
            }
            addEventDetail(title: "Time", description: timeText)
            do{
                let html = itemViewed.webLink
                let doc: Document = try SwiftSoup.parse(html)
                //print(doc)
                let p: Element = try doc.select("a").first()!
                let link: String = try p.attr("href")
                //print(link)
                addEventDetail(title: "Link", description: link)
            } catch{
                print("fail")
            }
            
            eventDetails.attributedText = attributedString
            
            
        } else {
            print("fail")
        }
        
    }
    
    func addEventDetail(title: String, description: String){
        let boldText = "\(title):\n"
        let attrs = [NSAttributedString.Key.font : UIFont.boldSystemFont(ofSize: 28)]
        let attributedString = NSMutableAttributedString(string:boldText, attributes:attrs)
        self.attributedString.append(attributedString)
        var normalText = description + "\n\n"
        let normalString = NSMutableAttributedString(string:normalText, attributes: [NSAttributedString.Key.font : UIFont.systemFont(ofSize: 20)])
        if description == ""{
            normalText = "N/A\n\n"
        }
        if title == "Linkk"{
            //let length = self.attributedString.length+normalText.count
            //self.attributedString.addAttribute(.link, value: "", range: self.attributedString.length, length)
        } else {
            self.attributedString.append(normalString)
        }

    }

}
