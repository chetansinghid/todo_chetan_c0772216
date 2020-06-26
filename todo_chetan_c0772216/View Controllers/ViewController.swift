//
//  ViewController.swift
//  todo_chetan_c0772216
//
//  Created by Chetan on 2020-06-24.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var categoryContext: NSManagedObjectContext!
    var resultsController: NSFetchedResultsController<Category>!
    
    var categoryName = UITextField()
    var categoryArray: [Category] = [Category]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        
        initializeCoreData()
        setUpTableView()
    }
    
    @IBAction func addCategory(_ sender: Any) {
        
        let alert = UIAlertController(title: "Let's add a category", message: "", preferredStyle: .alert)
        alert.addTextField(configurationHandler: addCategoryName(textField:))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { (action) in
            if(self.categoryName.text!.count < 1) {
                self.emptyFieldAlert()
                return
            }
            else {
                self.addNewCategory()
            }
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
    @IBAction func showInfo(_ sender: Any) {
        
        performSegue(withIdentifier: "noteListScreen", sender: self)
        
    }
    
    func emptyFieldAlert() {
        
        let alert = UIAlertController(title: "Oops!", message: "Name can't be empty", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
        
    }
    
    func addCategoryName(textField: UITextField) {
        
        self.categoryName = textField
        self.categoryName.placeholder = "Enter Category Name"
        
    }

}



//MARK: core data methods implemented
extension ViewController {
    
    
    func initializeCoreData() {
        print("initialized")
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        categoryContext = appDelegate.persistentContainer.viewContext
        
        fetchCategoryData()
        
    }
    
    
    func fetchCategoryData() {
//        request
        let request: NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
//        initialize
        request.sortDescriptors = [sortDescriptor]
        do {
            categoryArray = try categoryContext.fetch(request)
        } catch {
            print("Error loading categories: \(error.localizedDescription)")
        }
//        data fetched
        tableView.reloadData()
        
    }
    
    func addNewCategory() {
        print("addNewCategory")
        let categoryNames = self.categoryArray.map {$0.name}
        guard !categoryNames.contains(categoryName.text) else {self.showAlert(); return}
        let newCategory = Category(context: self.categoryContext)
        newCategory.name = categoryName.text!
        self.categoryArray.append(newCategory)
        do {
            try categoryContext.save()
            tableView.reloadData()
        } catch {
            print("Error saving categories \(error.localizedDescription)")
        }
        
    }
    
    
    func showAlert() {
        let alert = UIAlertController(title: "Category Already Exists!", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)

    }
    
}



extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
//    MARK: does inital table view setup
    func setUpTableView() {
        tableView.delegate = self
        tableView.dataSource = self
//        setup for auto size of cell
        tableView.estimatedRowHeight = 44
        tableView.rowHeight = UITableView.automaticDimension
    }
        
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categoryArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath)
        let category = categoryArray[indexPath.row]
        cell.textLabel?.text = category.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let delete = UIContextualAction(style: .destructive, title: "Delete") { (action, view, completion) in
            
                self.categoryContext.delete(self.categoryArray[indexPath.row])
                self.categoryArray.remove(at: indexPath.row)
                do {
                    try self.categoryContext.save()
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
}

