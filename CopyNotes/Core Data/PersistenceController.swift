//
//  PersistenceController.swift
//  CopyNotes
//
//  Created by Clive on 27/08/2024.
//

import Foundation
import CoreData

struct PersistenceController {
    
    static let shared = PersistenceController()
    
    let container: NSPersistentContainer
    
    init(inMemory: Bool = false) {
        self.container = NSPersistentContainer(name: "Notes")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { description, error in
            if let error = error  as NSError? {
                fatalError("Error loading container: \(error), \(error.userInfo)")
            }
        }
    }
    
    func save() {
        let context = container.viewContext
        
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("error saving context: \(error)")
        }
    }
    
    //MARK: - SwiftUI preview helper - might not need this
    
    static var preview: PersistenceController = {
       let controller = PersistenceController(inMemory: true)
       let context = controller.container.viewContext
        
        return controller
    }()
    
}
