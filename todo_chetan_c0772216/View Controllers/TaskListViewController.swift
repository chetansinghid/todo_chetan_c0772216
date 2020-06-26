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
    
    var selectedCategory: Category? {
        didSet {
            loadTodos()
        }
    }
    
    var categoryName: String!
    let todoListContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var tasksArray = [Todo]()
    var selectedTodo: Todo?
    
    //    outlets
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var sortSegment: UISegmentedControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpTableView()
        
    }
    
    
    @IBAction func addTodo(_ sender: Any) {
        performSegue(withIdentifier: "todoViewScreen", sender: self)
    }
    
    
    @IBAction func sortTodos(_ sender: Any) {
        //        fetchTaskData(sort: "date")
        //        fetchTaskData(sort: "name")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let destination = segue.destination as? TodoViewController {
            destination.delegate = self
            if selectedTodo != nil
            {
                destination.todo = selectedTodo
            }
        }
        
    }
    
}


//MARK: implement core data methods
extension TaskListViewController {
    
    func loadTodos(with request: NSFetchRequest<Todo> = Todo.fetchRequest(), predicate: NSPredicate? = nil) {
        
        let todoPredicate = NSPredicate(format: "parentFolder.name=%@", selectedCategory!.name!)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: true)]
        if let addtionalPredicate = predicate {
            request.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [todoPredicate, addtionalPredicate])
        } else {
            request.predicate = todoPredicate
        }
        
        do {
            tasksArray = try todoListContext.fetch(request)
        } catch {
            print("Error loading todos \(error.localizedDescription)")
        }
        
    }
    
    func deleteTodoFromList() {
        todoListContext.delete(selectedTodo!)
        tasksArray.removeAll { (Todo) -> Bool in
            Todo == selectedTodo!
        }
        tableView.reloadData()
    }
    
    
    func saveTodos() {
        do {
            try todoListContext.save()
        } catch {
            print("Error saving the context \(error.localizedDescription)")
        }
    }
    
    func updateTodo() {
        saveTodos()
        tableView.reloadData()
    }
    
    func markTodoCompleted() {
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        
        // predicate if you want
        let folderPredicate = NSPredicate(format: "name MATCHES %@", "Archived")
        request.predicate = folderPredicate
        do {
            let category = try todoListContext.fetch(request)
            self.selectedTodo?.parentFolder = category.first
            saveTodos()
            tableView.reloadData()
            
        } catch {
            print("Error fetching data \(error.localizedDescription)")
        }
        
    }
    
    func saveTodo(title: String, dueDate: Date)
    {
        let todo = Todo(context: todoListContext)
        todo.name = title
        todo.due_date = dueDate
        todo.date = Date()
        todo.parentFolder = selectedCategory
        saveTodos()
        tasksArray.append(todo)
        tableView.reloadData()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        selectedTodo = nil
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
            
//            self.saveTodos()
            tableView.deleteRows(at: [indexPath], with: .fade)
            completion(true)
        }
        
        delete.backgroundColor = #colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1)
        delete.image = UIImage(systemName: "trash.fill")
        return UISwipeActionsConfiguration(actions: [delete])
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedTodo = tasksArray[indexPath.row]
        performSegue(withIdentifier: "todoViewScreen", sender: self)
    }
}
