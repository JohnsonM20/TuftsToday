//
//  ViewEventDetailsViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/17/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit

protocol ViewEventDetailsViewControllerDelegate: class {
    //func addItemViewControllerDidCancel(controller: AddItemViewController)
    func viewEventDetailsViewController(controller: ViewEventDetailsViewController)
    //func viewEventDetailsViewController(_ controller: AddItemViewController, didFinishEditing item: ChecklistItem)
}

class ViewEventDetailsViewController: UITableViewController {

    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var about: UILabel!
    weak var delegate: ViewEventDetailsViewControllerDelegate?
    //@IBOutlet weak var doneBarButton: UIBarButtonItem!
    var itemViewed: Event?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        
        
        if let itemViewed = itemViewed  {
            title = "Event Details"
            name.text = itemViewed.title
            about.text = itemViewed.description
        } else {
            print("fail")
        }
        
    }

}
