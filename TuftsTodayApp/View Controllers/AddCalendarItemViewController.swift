//
//  AddCalendarItemViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/16/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit

protocol addCalendarItemViewControllerDelegate: class {
    func addCalendarItemViewControllerDidCancel(_ controller: AddCalendarItemViewController)
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishAdding item: CalendarItem)
    func addCalendarItemViewController(_ controller: AddCalendarItemViewController, didFinishEditing item: CalendarItem)
}

class AddCalendarItemViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doneBarButton: UIBarButtonItem!
    weak var delegate: addCalendarItemViewControllerDelegate?
    var itemToEdit: CalendarItem?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        
        if let item = itemToEdit {
            title = "Edit Item"
            textField.text = item.title
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
        if let item = itemToEdit {
            item.title = textField.text!
            delegate?.addCalendarItemViewController(self,didFinishEditing: item)
        } else {
            let item = CalendarItem()
            item.title = textField.text!
            delegate?.addCalendarItemViewController(self, didFinishAdding: item)
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
