//
//  TaskListViewController.swift
//  todo_chetan_c0772216
//
//  Created by Chetan on 2020-06-25.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit

class TaskListViewController: UIViewController {
    
    var categoryName: String!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    
    @IBAction func addTodo(_ sender: Any) {
        
        
    }
    
    
    @IBAction func sortTodos(_ sender: Any) {
    }
    
}
