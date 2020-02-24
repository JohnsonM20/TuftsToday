//
//  CalendarViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/14/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit

class CalendarItem: NSObject, Encodable, Decodable {
    
    var title: String = ""
}

class CalendarViewController: UITableViewController, addCalendarItemViewControllerDelegate {
    func addCalendarItemViewControllerDidCancel(_ controller: AddCalendarItemViewController) {
        navigationController?.popViewController(animated:true)
    }
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishAdding item: CalendarItem) {
        let newRowIndex = calendarList.count
        calendarList.append(item)
        let indexPath = IndexPath(row: newRowIndex, section: 0)
        let indexPaths = [indexPath]
        tableView.insertRows(at: indexPaths, with: .automatic)
        navigationController?.popViewController(animated:true)
        saveCalendarItems()
    }
    
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishEditing item: CalendarItem) {
        if let index = calendarList.firstIndex(of: item) {
            let indexPath = IndexPath(row: index, section: 0)
            if let cell = tableView.cellForRow(at: indexPath) {
                configureText(for: cell, with: item)
            }
        }
        navigationController?.popViewController(animated:true)
        saveCalendarItems()
    }
    
    var calendarList: [CalendarItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = true
        
        loadCalendarItems()

    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return calendarList.count
    }
    
    @IBAction func editClasses(_ sender: Any) {
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "CalendarItem", for: indexPath)
        cell.selectionStyle = .none;
        
        let item = calendarList[indexPath.row]
        configureText(for: cell, with: item)
        
        return cell

    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        calendarList.remove(at: indexPath.row)
        let indexPaths = [indexPath]
        tableView.deleteRows(at: indexPaths, with: .automatic)
        saveCalendarItems()
    }
    
    func configureText(for cell: UITableViewCell, with item: CalendarItem) {
        let label = cell.viewWithTag(99) as! UILabel
        label.text = item.title
        
    }
    
    func documentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            return paths[0]
    }
    
    func dataFilePath() -> URL {
        return documentsDirectory().appendingPathComponent("Calendar.plist")
    }
    
    func saveCalendarItems() {
      let encoder = PropertyListEncoder()
      do {
        let data = try encoder.encode(calendarList)
        try data.write(to: dataFilePath(), options: Data.WritingOptions.atomic)
        } catch {
        print("Error encoding item array: \(error.localizedDescription)")
        }
    }
    
    func loadCalendarItems() {
      let path = dataFilePath()
      if let data = try? Data(contentsOf: path) {
        let decoder = PropertyListDecoder()
        do {
            calendarList = try decoder.decode([CalendarItem].self, from: data)
        } catch {
            print("Error decoding item array: \(error.localizedDescription)") }
        }
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
                controller.itemToEdit = calendarList[indexPath.row]
            }
        }
    }
}
