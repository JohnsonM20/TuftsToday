//
//  CalendarViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/14/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import CoreData

class CalendarViewController: UITableViewController, addCalendarItemViewControllerDelegate {
    func addCalendarItemViewControllerDidCancel(_ controller: AddCalendarItemViewController) {
        navigationController?.popViewController(animated:true)
    }
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishAdding name: String, date: Date, endDate: Date, remind: Bool, id: String) {
        addItem(name: name, date: date, endDate: endDate, remind: remind, id: id)
        navigationController?.popViewController(animated:true)
        reloadCalendar()
    }
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishEditing name: String, date: Date, endDate: Date, remind: Bool, id: String) {
        editItem(name: name, date: date, endDate: endDate, remind: remind, id: id)
        navigationController?.popViewController(animated:true)
        reloadCalendar()
    }
    
    var calendarItems: [CalendarItemData] = []
    var calendarAndDateList: [Any] = []
    
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
    
    override func tableView(_ tableView: UITableView, commit editingStyle:UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            deleteItem(row: indexPath.row)
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
        
        let startTime = Formatter.dateFormatter(dateString: (item.value(forKeyPath: "startDate") as? Date)!.description, originalFormat: "\(timeTypes.ZFormat)", convertTo: "\(timeTypes.toTimeOfDay)")
        let endTime = Formatter.dateFormatter(dateString: (item.value(forKeyPath: "endDate") as? Date)!.description, originalFormat: "\(timeTypes.ZFormat)", convertTo: "\(timeTypes.toTimeOfDay)")
        
        if Formatter.dateFormatter(dateString: (item.value(forKeyPath: "startDate") as? Date)!.description, originalFormat: "\(timeTypes.ZFormat)", convertTo: "\(timeTypes.toDate)") == Formatter.dateFormatter(dateString: (item.value(forKeyPath: "endDate") as? Date)!.description, originalFormat: "\(timeTypes.ZFormat)", convertTo: "\(timeTypes.toDate)"){
            
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
    
    func addItem(name: String, date: Date, endDate: Date, remind: Bool, id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CalendarItemData", in: managedContext)!
        let item = CalendarItemData(entity: entity, insertInto: managedContext)
        
        item.setValue(name, forKeyPath: "name")
        item.setValue(date, forKey: "startDate")
        item.setValue(endDate, forKey: "endDate")
        item.setValue(remind, forKey: "shouldRemind")
        item.setValue(id, forKey: "itemID")
        
        do {
            try managedContext.save()
            calendarItems.append(item)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        reloadCalendar()
        item.scheduleNotification()
    }
    
    func editItem(name: String, date: Date, endDate: Date, remind: Bool, id: String){
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
            
            item.scheduleNotification()
        }
        
      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func deleteItem(row: Int){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        if let item = calendarItems.first(where: { $0.itemID == (calendarAndDateList[row] as! CalendarItemData).itemID }) {
            managedContext.delete(item)
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
            let startDate = Formatter.dateFormatter(dateString: event.startDate.description, originalFormat: "\(timeTypes.ZFormat)", convertTo: "\(timeTypes.toDate)")

            if index == 0 || startDate != Formatter.dateFormatter(dateString: calendarItems[index-1].startDate.description, originalFormat: "\(timeTypes.ZFormat)", convertTo: "\(timeTypes.toDate)"){
                
                let dateFormatter = DateFormatter()
                dateFormatter.locale = Locale(identifier: "en_US_POSIX")
                dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
                let itemDate = dateFormatter.date(from: event.startDate.description)!
                
                if itemDate <= Date() && index != 0{ // deletes past events
                    deleteItem(row: index)
                    return
                    
                } else { // adds date header to row before next event
                    let dateHeader = EventRow(title: "\(startDate)")
                    calendarAndDateList.append(dateHeader)
                }
            }
            calendarAndDateList.append(event)
            index += 1
        }
        self.tableView.reloadData()
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
