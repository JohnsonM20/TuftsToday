//
//  CalendarViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/14/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import CoreData

class CalendarViewController: UITableViewController, AddCalendarItemViewControllerDelegate, AddEventToCalendarVCDelegate{
    
    //AddCalendarItemViewControllerDelegate___________________________________________
    func addCalendarItemViewControllerDidCancel(_ controller: AddCalendarItemViewController) {
        navigationController?.popViewController(animated:true)
    }
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishAdding name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String) {
        addItem(name: name, desc: desc, date: date, endDate: endDate, remind: remind, id: id)
        navigationController?.popViewController(animated:true)
        reloadCalendar()
    }
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishEditing name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String) {
        editItem(name: name, desc: desc, date: date, endDate: endDate, remind: remind, id: id)
        navigationController?.popViewController(animated:true)
        reloadCalendar()
    }
    
    //AddEventToCalendarVCDelegate___________________________________________
    func addEventVC(_ controller: ViewEventDetailsViewController, didAdd name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String) {
        addItem(name: name, desc: desc, date: date, endDate: endDate, remind: remind, id: id)
    }
    
    func deleteEventVC(_ controller: ViewEventDetailsViewController, didDelete id: String) {
        deleteItem(id: id)
    }
    
    var calendarItems: [CalendarItemData] = []
    var calendarAndDateList: [Any] = []
    var todayRow: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillAppear(_ animated: Bool) { //runs after viewDidLoad
        super.viewWillAppear(animated)
        reloadCalendar()
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarAndDateList.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func editClasses(_ sender: Any) {
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell { //adds all cells from CalendarAndDateList
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarItem", for: indexPath)
        
        if let calendarEvent = calendarAndDateList[indexPath.row] as? CalendarItemData {
            configureText(for: cell, with: calendarEvent)
            return cell
        } else if let eventDay = calendarAndDateList[indexPath.row] as? EventRow{
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewDay", for: indexPath)
            let date = cell.viewWithTag(96) as! UILabel
            date.text = eventDay.title
            return cell
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteItem(id: (calendarAndDateList[indexPath.row] as! CalendarItemData).itemID)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if calendarAndDateList[indexPath.row] is CalendarItemData{
            return true
        } else {
            return false
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: CalendarItemData) {
        let name = cell.viewWithTag(99) as! UILabel
        let date = cell.viewWithTag(100) as! UILabel
        
        let startTime = Formatter.dateFormatterToString(dateString: (item.value(forKeyPath: "startDate") as? Date)!.description, originalFormat: "\(timeTypes.ymdZFormat)", convertTo: "\(timeTypes.toTimeOfDay)")
        let endTime = Formatter.dateFormatterToString(dateString: (item.value(forKeyPath: "endDate") as? Date)!.description, originalFormat: "\(timeTypes.ymdZFormat)", convertTo: "\(timeTypes.toTimeOfDay)")
        
        if Formatter.dateFormatterToString(dateString: (item.value(forKeyPath: "startDate") as? Date)!.description, originalFormat: "\(timeTypes.ymdZFormat)", convertTo: "\(timeTypes.toDate)") == Formatter.dateFormatterToString(dateString: (item.value(forKeyPath: "endDate") as? Date)!.description, originalFormat: "\(timeTypes.ymdZFormat)", convertTo: "\(timeTypes.toDate)"){
            
            if startTime != endTime{
                date.text = startTime + " - " + "\(endTime)"
            } else { // startTime = endTime
                date.text = startTime
            }
        } else { // if startDate != endDate
            date.text = startTime
        }
        name.text = item.value(forKeyPath: "name") as? String
    }
    
    func addItem(name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CalendarItemData", in: managedContext)!
        let item = CalendarItemData(entity: entity, insertInto: managedContext)
        
        item.setValue(name, forKeyPath: "name")
        item.setValue(date, forKey: "startDate")
        item.setValue(endDate, forKey: "endDate")
        item.setValue(remind, forKey: "shouldRemind")
        item.setValue(id, forKey: "itemID")
        item.setValue(desc, forKey: "eventDescription")
        
        do {
            try managedContext.save()
            calendarItems.append(item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        reloadCalendar()
        item.scheduleNotification()
    }
    
    func editItem(name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CalendarItemData>(entityName: "CalendarItemData")
        let filterPredicate = NSPredicate(format: "itemID == %@", id)
        fetchRequest.predicate = filterPredicate

        if let item = calendarItems.first(where: { $0.itemID == id }) {
            item.setValue(name, forKeyPath: "name")
            item.setValue(date, forKey: "startDate")
            item.setValue(endDate, forKey: "endDate")
            item.setValue(remind, forKey: "shouldRemind")
            item.setValue(id, forKey: "itemID")
            item.setValue(desc, forKey: "eventDescription")
            
            item.scheduleNotification()
        }
        
      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func deleteItem(id: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CalendarItemData>(entityName: "CalendarItemData")
        do {
            let results = try managedContext.fetch(fetchRequest)
            for result in results{
                if let resultID = result.value(forKey: "itemID") as? String{
                    //print("Got device named " + resultID)
                    if id == resultID{
                        managedContext.delete(result)
                    }
                }
            }
        } catch let error as NSError {
          print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // TODO:- queue reload data to run after tableview deletes row to make animation possible
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not delete. \(error), \(error.userInfo)")
        }
        reloadCalendar()
     }
    
    func reloadCalendar(){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CalendarItemData>(entityName: "CalendarItemData")
        let sectionSortDescriptor = NSSortDescriptor(key: "startDate", ascending: true)
        let sortDescriptors = [sectionSortDescriptor]
        fetchRequest.sortDescriptors = sortDescriptors
        
        do {
            calendarItems = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        calendarAndDateList = []
        var index = 0
        for event in calendarItems{
            let startDate = Formatter.dateFormatterToString(dateString: event.startDate.description, originalFormat: "\(timeTypes.ymdZFormat)", convertTo: "\(timeTypes.toDate)")

            if index == 0 || startDate != Formatter.dateFormatterToString(dateString: calendarItems[index-1].startDate.description, originalFormat: "\(timeTypes.ymdZFormat)", convertTo: "\(timeTypes.toDate)"){
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                
                if event.startDate <= Date(){
                    todayRow = calendarAndDateList.count
                    print(todayRow)
                }
                
                // adds date header to row before next event
                let dateHeader = EventRow(title: "\(startDate)")
                calendarAndDateList.append(dateHeader)
            }
            calendarAndDateList.append(event)
            index += 1
        }
        self.tableView.reloadData()
        //self.tableView.scrollToRow(at: IndexPath(row: todayRow, section: 0), at: UITableView.ScrollPosition.top, animated: true)
    }
    
    // MARK:- Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AddItem" {
            let controller = segue.destination as! AddCalendarItemViewController
            controller.delegate = self
            
        } else if segue.identifier == "EditItem" {
            let controller = segue.destination as! AddCalendarItemViewController
            controller.delegate = self
            
            if let indexPath = tableView.indexPath(for: sender as! UITableViewCell) {
                controller.itemToEdit = (calendarAndDateList[indexPath.row] as! CalendarItemData)
            }
        }
    }
}
