//
//  AddCalendarItemViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/16/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import CoreData

protocol addCalendarItemViewControllerDelegate: class {
    func addCalendarItemViewControllerDidCancel(_ controller: AddCalendarItemViewController)
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishAdding name: String, date: Date, remind: Bool, id: String)
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishEditing name: String, date: Date, remind: Bool, id: String)
}

class AddCalendarItemViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var reminder: UISegmentedControl!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    
    weak var delegate: addCalendarItemViewControllerDelegate?
    var itemToEdit: CalendarItemData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        datePicker.minimumDate = Date()
        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.name
            datePicker.date = item.date!
            
            if item.shouldRemind == true{
                reminder.selectedSegmentIndex = 0
            } else {
                reminder.selectedSegmentIndex = 1
            }
            doneBarButton.isEnabled = true
        }
            
    }
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        textField.becomeFirstResponder()
    }
    
    // MARK:- Actions
    @IBAction func cancel() {
        delegate?.addCalendarItemViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        let name = textField.text!
        let date = datePicker.date
        var remind = true
        
        if reminder.selectedSegmentIndex != 0{
            remind = false
        }
        if itemToEdit != nil {
            delegate?.addCalendarItemViewController(self,didFinishEditing: name, date: date, remind: remind, id: itemToEdit!.itemID)
        } else {
            delegate?.addCalendarItemViewController(self, didFinishAdding: name, date: date, remind: remind, id: UUID().uuidString)
        }
        
    }
    
    // MARK:- Text Field Delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text!
        let stringRange = Range(range, in:oldText)!
        let newText = oldText.replacingCharacters(in: stringRange, with: string)
        if newText.isEmpty {
            doneBarButton.isEnabled = false
        } else {
            doneBarButton.isEnabled = true
        }
        return true
    }
}
