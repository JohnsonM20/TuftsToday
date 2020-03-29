//
//  AddCalendarItemViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/16/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

protocol AddCalendarItemViewControllerDelegate: class {
    func addCalendarItemViewControllerDidCancel(_ controller: AddCalendarItemViewController)
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishAdding name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String)
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishEditing name: String, desc: String, date: Date, endDate: Date, remind: Bool, id: String)
}

class AddCalendarItemViewController: UITableViewController, UITextFieldDelegate, UITextViewDelegate {

    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var descriptionField: UITextView!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    @IBOutlet weak var shouldRemindSwitch: UISwitch!
    
    @IBOutlet weak var dueDateLabel: UILabel!
    @IBOutlet weak var endDateLabel: UILabel!
    
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var datePickerCell: UITableViewCell!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePickerCell: UITableViewCell!
    
    var dueDate = Date()
    var datePickerVisible = false
    var endDate = Date()
    var endDatePickerVisible = false
    
    weak var delegate: AddCalendarItemViewControllerDelegate?
    var itemToEdit: CalendarItemData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        datePicker.minimumDate = Date()
        
        descriptionField.delegate = self
        
        descriptionField.becomeFirstResponder()
        descriptionField.selectedTextRange = descriptionField.textRange(from: descriptionField.beginningOfDocument, to: descriptionField.beginningOfDocument)

        
        if let item = itemToEdit {
            title = "Edit Item"
            nameField.text = item.name
            descriptionField.text = item.eventDescription
            datePicker.date = item.startDate
            endDatePicker.date = item.endDate
            
            shouldRemindSwitch.isOn = item.shouldRemind
            dueDate = item.startDate
            endDate = item.endDate
            doneBarButton.isEnabled = true
        } else {
            descriptionField.text = "Event Description"
            descriptionField.textColor = UIColor.lightGray
        }
        updateDateLabel(isStartDate: true)
        updateDateLabel(isStartDate: false)
    }
    
    // MARK:- Table View Delegates
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if (indexPath.section == 1 && indexPath.row == 1) || (indexPath.section == 2 && indexPath.row == 0){
            return indexPath
        } else {
            return nil
        }
    }
    
    override func viewWillAppear(_ animated: Bool) { super.viewWillAppear(animated)
        nameField.becomeFirstResponder()
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if indexPath.section == 1 && indexPath.row == 2 {
        return datePickerCell
    } else if indexPath.section == 2 && indexPath.row == 1 {
        return endDatePickerCell
    } else {
        return super.tableView(tableView, cellForRowAt: indexPath) }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 1 && datePickerVisible {
            return 3
        } else if section == 2 && endDatePickerVisible{
            return 2
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.section == 1 && indexPath.row == 2) || (indexPath.section == 2 && indexPath.row == 1){
            return 217
        } else {
            return super.tableView(tableView, heightForRowAt: indexPath) }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        nameField.resignFirstResponder()
        if indexPath.section == 1 && indexPath.row == 1{
            if endDatePickerVisible {
                hideDatePicker(isStartDate: false)
            }
            if !datePickerVisible {
                showDatePicker(isStartDate: true)
            } else {
                hideDatePicker(isStartDate: true)
            }
        } else if indexPath.section == 2 && indexPath.row == 0{
            if datePickerVisible {
                hideDatePicker(isStartDate: true)
            }
            if !endDatePickerVisible {
                showDatePicker(isStartDate: false)
            } else {
                hideDatePicker(isStartDate: false)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, indentationLevelForRowAt indexPath: IndexPath) -> Int {
        var newIndexPath = indexPath
        if indexPath.section == 1 && indexPath.row == 2 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        } else if indexPath.section == 2 && indexPath.row == 1 {
            newIndexPath = IndexPath(row: 0, section: indexPath.section)
        }
        return super.tableView(tableView, indentationLevelForRowAt: newIndexPath)
    }
    
    // MARK:- Actions
    @IBAction func cancel() {
        delegate?.addCalendarItemViewControllerDidCancel(self)
    }
    
    @IBAction func done() {
        nameField.resignFirstResponder()
        if shouldRemindSwitch.isOn {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert, .sound]) {
                granted, error in
            }
        }
        
        let name = nameField.text!
        let remind = shouldRemindSwitch.isOn
        let desc = descriptionField.text
        
        if itemToEdit != nil {
            delegate?.addCalendarItemViewController(self, didFinishEditing: name, desc: desc ?? "", date: dueDate, endDate: endDate, remind: remind, id: itemToEdit!.itemID)
        } else {
            delegate?.addCalendarItemViewController(self, didFinishAdding: name, desc: desc ?? "", date: dueDate, endDate: endDate, remind: remind, id: UUID().uuidString)
        }
    }
    
    @IBAction func startDateChanged(_ datePicker: UIDatePicker) {
        dueDate = datePicker.date
        updateDateLabel(isStartDate: true)
        endDatePicker.minimumDate = dueDate
        if dueDate > endDate {
            endDate = dueDate
            endDatePicker.date = endDate
            updateDateLabel(isStartDate: false)
        }
    }
    
    @IBAction func endDateChanged(_ datePicker: UIDatePicker) {
        endDate = datePicker.date
        updateDateLabel(isStartDate: false)
    }
    
    // MARK:- Helper Methods
    func updateDateLabel(isStartDate: Bool) {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        if isStartDate{
            dueDateLabel.text = formatter.string(from: dueDate)
        } else {
            endDateLabel.text = formatter.string(from: endDate)
        }
    }
    
    func showDatePicker(isStartDate: Bool) {
        if isStartDate{
            datePickerVisible = true
            let indexPathDatePicker = IndexPath(row: 2, section: 1)
            tableView.insertRows(at: [indexPathDatePicker], with: .fade)
            dueDateLabel.textColor = dueDateLabel.tintColor
        } else {
            endDatePickerVisible = true
            let indexPathDatePicker = IndexPath(row: 1, section: 2)
            tableView.insertRows(at: [indexPathDatePicker], with: .fade)
            endDateLabel.textColor = dueDateLabel.tintColor
        }
    }
    
    func hideDatePicker(isStartDate: Bool) {
        if isStartDate{
            if datePickerVisible {
                datePickerVisible = false
                let indexPathDatePicker = IndexPath(row: 2, section: 1)
                tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
                dueDateLabel.textColor = UIColor.black
            }
        } else {
            if endDatePickerVisible {
                endDatePickerVisible = false
                let indexPathDatePicker = IndexPath(row: 1, section: 2)
                tableView.deleteRows(at: [indexPathDatePicker], with: .fade)
                endDateLabel.textColor = UIColor.black
            }
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
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {

        // Combine the textView text and the replacement text to
        // create the updated text string
        let currentText:String = textView.text
        let updatedText = (currentText as NSString).replacingCharacters(in: range, with: text)

        // If updated text view will be empty, add the placeholder
        // and set the cursor to the beginning of the text view
        if updatedText.isEmpty {

            textView.text = "Event Description"
            textView.textColor = UIColor.lightGray

            textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
        }

        // Else if the text view's placeholder is showing and the
        // length of the replacement string is greater than 0, set
        // the text color to black then set its text to the
        // replacement string
         else if textView.textColor == UIColor.lightGray && !text.isEmpty {
            textView.textColor = UIColor.black
            textView.text = text
        }

        // For every other case, the text should change with the usual
        // behavior...
        else {
            return true
        }

        // ...otherwise return false since the updates have already
        // been made
        return false
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        if self.view.window != nil {
            if textView.textColor == UIColor.lightGray {
                textView.selectedTextRange = textView.textRange(from: textView.beginningOfDocument, to: textView.beginningOfDocument)
            }
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        hideDatePicker(isStartDate: true)
        hideDatePicker(isStartDate: false)
    }
}
