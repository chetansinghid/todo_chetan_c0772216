//
//  TaskListViewController.swift
//  todo_chetan_c0772216
//
//  Created by Chetan on 2020-06-25.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit
import CoreData

class TaskListViewController: UIViewController {
    
    var categoryName: String!
    var selectedTodo: Int!
    var todoListContext: NSManagedObjectContext!
    var tasksArray = [Todo]()
//    delegate variables for todo screen
    
    var isComplete: Bool = false
    var isDeleted: Bool = false
    var isSaved: Bool = false
    var isNew: Bool = false
    var isDiscard: Bool = false
    var updatedTitle: String!
    var updatedTime: Date!
    
//    outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeCoreData()
        setUpTableView()
        
    }
    
    
    @IBAction func addTodo(_ sender: Any) {
        isNew = true
        performSegue(withIdentifier: "todoViewScreen", sender: self)
    }
    
    
    @IBAction func sortTodos(_ sender: Any) {
        fetchTaskData(sort: "date")
        fetchTaskData(sort: "name")
    }
    
    @IBAction func unwind( _ seg: UIStoryboardSegue) {
        if(isComplete) {
            markCompleted()
        }
        if(isSaved) {
            saveTodo()
            
        }
        if(isDeleted) {
            deleteTodo()
        }
        if(isDiscard) {
//            nothing to be done
            if(selectedTodo != nil) {
                selectedTodo = nil
            }
        }
        
    }
    
}

//MARK: implement delegate methods
extension TaskListViewController {
    
    func markCompleted() {
        if(!isNew) {
            
        }
        isNew = false
    }
    
    func saveTodo() {
        if(isNew) {
            addNewTodo()
        }
        else {
            updateTodo()
        }
        isNew = false
    }
    
    func deleteTodo() {
        if(!isNew) {
            
        }
        isNew = false
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if(!isNew) {
            if let destinationView = segue.destination as? TodoViewController {
                destinationView.titleText = tasksArray[selectedTodo].name
                destinationView.date = tasksArray[selectedTodo].due_date
            }
        }
    }
    
}

//MARK: implement core data methods
extension TaskListViewController {
    func initializeCoreData() {
            print("initialized")
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            todoListContext = appDelegate.persistentContainer.viewContext
            
            fetchTaskData(sort: "date")
            
        }
        
        
    func fetchTaskData(sort: String) {
    //        request
            let request: NSFetchRequest<Todo> = Todo.fetchRequest()
            let sortDescriptor = NSSortDescriptor(key: sort, ascending: true)
    //        initialize
            request.sortDescriptors = [sortDescriptor]
            do {
                tasksArray = try todoListContext.fetch(request)
            } catch {
                print("Error loading categories: \(error.localizedDescription)")
            }
    //        data fetched
            tableView.reloadData()
            
    }
        
    func addNewTodo() {

        let newTodo = Todo(context: self.todoListContext)
        newTodo.name = updatedTitle
        newTodo.date = Date()
        newTodo.due_date = updatedTime
        self.tasksArray.append(newTodo)
        do {
            try todoListContext.save()
            tableView.reloadData()
        } catch {
            print("Error saving categories \(error.localizedDescription)")
        }
        
    }
    
    func updateTodo() {
        
        let date = tasksArray[selectedTodo].date
        self.todoListContext.delete(self.tasksArray[selectedTodo])
        self.tasksArray.remove(at: selectedTodo)
        do {
            try self.todoListContext.save()
        } catch {
            print("Error saving the context \(error.localizedDescription)")
        }
        let newTodo = Todo(context: self.todoListContext)
        newTodo.name = updatedTitle
        newTodo.date = date
        newTodo.due_date = updatedTime
        self.tasksArray.insert(newTodo, at: selectedTodo)
        do {
            try todoListContext.save()
            tableView.reloadData()
        } catch {
            print("Error saving categories \(error.localizedDescription)")
        }
    }
    
    func removeTodo() {
        
        self.todoListContext.delete(self.tasksArray[selectedTodo])
        self.tasksArray.remove(at: selectedTodo)
        do {
            try self.todoListContext.save()
        } catch {
            print("Error saving the context \(error.localizedDescription)")
        }
        tableView.reloadData()
    }
}


extension TaskListViewController: UITableViewDelegate, UITableViewDataSource {
    //    MARK: does inital table view setup
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
//        setup for auto size of cell
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tasksArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "todoCell", for: indexPath)
        let task = tasksArray[indexPath.row]
        cell.textLabel?.text = task.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
                self.todoListContext.delete(self.tasksArray[indexPath.row])
                self.tasksArray.remove(at: indexPath.row)
                do {
                    try self.todoListContext.save()
                } catch {
                    print("Error saving the context \(error.localizedDescription)")
                }
                
                //        reloads data
                self.tableView.reloadData()
                completion(true)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        delete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTodo = indexPath.row
        performSegue(withIdentifier: "todoViewScreen", sender: self)
    }
    
    
}
