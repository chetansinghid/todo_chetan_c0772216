//
//  CoreDataHandler.swift
//  todo_chetan_c0772216
//
//  Created by Chetan on 2020-06-25.
//  Copyright © 2020 Chetan. All rights reserved.
//

import UIKit
import CoreData

class CoreDataHandler {
    var container: NSPersistentContainer {
        let container = NSPersistentContainer(name: "Category")
        container.loadPersistentStores { (description, error) in
            guard error == nil else {
                print(error!)
                return
            }
        }
        return container
    }
    
    var managedObjectContext: NSManagedObjectContext {
        return container.viewContext
    }
    
    
}
