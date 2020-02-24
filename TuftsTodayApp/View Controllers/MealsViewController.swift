//
//  MealsViewController.swift
//  TuftsTodayApp
//
//  Created by Matthew Johnson on 2/16/20.
//  Copyright © 2020 Matthew Johnson. All rights reserved.
//

import UIKit
import SwiftSoup

class MealsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //https://dining.tufts.edu/
    //http://menus.tufts.edu/foodpro/shortmenu.asp?sName=TUFTS+DINING&locationNum=09&locationName=Carmichael+Dining+Center&naFlag=1&WeeksMenus=This+Week%27s+Menus&myaction=read&dtdate=2%2F16%2F2020

        do {
            let urlString = String(format:"http://menus.tufts.edu/foodpro/longmenu.asp?sName=TUFTS+DINING&locationNum=09&locationName=Carmichael+Dining+Center&naFlag=1&WeeksMenus=This+Week%27s+Menus&dtdate=2%2F29%2F2020&mealName=Lunch")
            let url = URL(string: urlString)
            //print(0)
            let html = try String(contentsOf: url!, encoding: .utf8)
            //print(1)
            let doc: Document = try SwiftSoup.parse(html)
            //print(2)

            let test: String = try doc.attr("tr")

        } catch Exception.Error(let type, let message) {
            print(message)
        } catch {
            print("error")
        }
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}
