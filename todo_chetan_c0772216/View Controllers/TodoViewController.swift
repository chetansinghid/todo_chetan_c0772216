//
//  TodoViewController.swift
//  todo_chetan_c0772216
//
//  Created by Chetan on 2020-06-25.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit
import CoreData

class TodoViewController: UIViewController {
    
    enum exitCode {
        case save
        case delete
        case completed
    }
    
    var exitStatus: exitCode!
    
    @IBOutlet weak var todoTitleLabel: UITextField!
    var titleText: String?
    var date: Date?
    @IBOutlet weak var deadlineLabel: UIDatePicker!
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        if let text = titleText {
            todoTitleLabel.text = text
        }
        if let dateVal = date {
            deadlineLabel.date = dateVal
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationView = segue.destination as? TaskListViewController {
            switch exitStatus {
            case .completed:
                destinationView.isComplete = true
                destinationView.updatedTitle = todoTitleLabel.text
                destinationView.updatedTime = deadlineLabel.date
            case .delete:
                destinationView.isDeleted = true
            case .save:
                destinationView.isSaved = true
                destinationView.updatedTitle = todoTitleLabel.text
                destinationView.updatedTime = deadlineLabel.date
            default:
                destinationView.isDiscard = true
            }
        }
    }
    
    
    @IBAction func saveTask(_ sender: Any) {
        if(checkTitle()) {
            exitStatus = exitCode.save
            performSegue(withIdentifier: "goBackToList", sender: self)
        }
    }
    @IBAction func markCompleted(_ sender: Any) {
        if(checkTitle()) {
             exitStatus = exitCode.completed
             performSegue(withIdentifier: "goBackToList", sender: self)
        }
    }
    @IBAction func deleteTask(_ sender: Any) {
        exitStatus = exitCode.delete
        performSegue(withIdentifier: "goBackToList", sender: self)
    }
    
    func checkTitle() -> Bool {
        if (todoTitleLabel.text?.isEmpty ?? true) {
            let alert = UIAlertController(title: "Title can't be blank!", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return false
        }
        else {
            return true
        }
    }
}

