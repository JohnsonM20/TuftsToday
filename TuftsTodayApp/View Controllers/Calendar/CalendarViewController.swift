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
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishAdding name: String, date: Date, remind: Bool, id: String) {
        addItem(name: name, date: date, remind: remind, id: id)
        navigationController?.popViewController(animated:true)
        self.tableView.reloadData()
    }
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishEditing name: String, date: Date, remind: Bool, id: String) {
        editItem(name: name, date: date, remind: remind, id: id)
        navigationController?.popViewController(animated:true)
        self.tableView.reloadData()
    }
    
    var calendarItems: [CalendarItemData] = []
    var lastIDClicked: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
      let managedContext = appDelegate.persistentContainer.viewContext
      let fetchRequest = NSFetchRequest<CalendarItemData>(entityName: "CalendarItemData")

      do {
        calendarItems = try managedContext.fetch(fetchRequest)
      } catch let error as NSError {
        print("Could not fetch. \(error), \(error.userInfo)")
      }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarItems.count
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //if let cell = tableView.cellForRow(at: indexPath){
        //}
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    @IBAction func editClasses(_ sender: Any) {
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let item = calendarItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarItem", for: indexPath)
        configureText(for: cell, with: item)
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete{
            guard let appDelegate =
              UIApplication.shared.delegate as? AppDelegate else {
              return
            }
              
            let managedContext = appDelegate.persistentContainer.viewContext
            managedContext.delete(calendarItems[indexPath.row])
            
            calendarItems.remove(at: indexPath.row) 
            //tableView.deleteRows(at: [indexPath], with: .fade)
            self.tableView.reloadData()
            
            do {
              try managedContext.save()
            } catch let error as NSError {
              print("Could not delete. \(error), \(error.userInfo)")
            }
        }
    }
    
    func configureText(for cell: UITableViewCell, with item: CalendarItemData) {
        let name = cell.viewWithTag(99) as! UILabel
        let date = cell.viewWithTag(100) as! UILabel
        let time = dateFormatter(dateString: (item.value(forKeyPath: "date") as? Date)!.description)
        
        name.text = item.value(forKeyPath: "name") as? String
        date.text = time
        
    }
    
    func addItem(name: String, date: Date, remind: Bool, id: String) {
        print("ADDING NEW ITEM \(name)")
      guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
        return
      }
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "CalendarItemData", in: managedContext)!
        let item = CalendarItemData(entity: entity, insertInto: managedContext)
        
        item.setValue(name, forKeyPath: "name")
        item.setValue(date, forKey: "date")
        item.setValue(remind, forKey: "shouldRemind")
        item.setValue(id, forKey: "itemID")
        
      do {
        try managedContext.save()
        calendarItems.append(item)
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func editItem(name: String, date: Date, remind: Bool, id: String){
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<CalendarItemData>(entityName: "CalendarItemData")
        let filterPredicate = NSPredicate(format: "itemID == %@", id)
        fetchRequest.predicate = filterPredicate

        if let item = calendarItems.first(where: { $0.itemID == id }) {
            print("The first negative number is \(id).")
            item.setValue(name, forKeyPath: "name")
            item.setValue(date, forKey: "date")
            item.setValue(remind, forKey: "shouldRemind")
            item.setValue(id, forKey: "itemID")
        }
        
      do {
        try managedContext.save()
      } catch let error as NSError {
        print("Could not save. \(error), \(error.userInfo)")
      }
    }
    
    func dateFormatter(dateString: String) -> String{
        //https://nsdateformatter.com/
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ssZ"
        let date = dateFormatter.date(from: dateString)!
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "h:mm a"
        return dateFormatterPrint.string(from: date)
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
                controller.itemToEdit = calendarItems[indexPath.row]
            }
        }
    }
}
