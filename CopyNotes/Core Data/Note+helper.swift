//
//  Note+helper.swift
//  CopyNotes
//
//  Created by Clive on 27/08/2024.
//

import Foundation
import CoreData

extension Note {
    
    var num: Int {
        get {Int(num_)}
        set {num_ = Int32(newValue)}
    }
    
    var title: String {
        get { title_ ?? "New Title" }
        set { title_ = newValue }
    }
    
    var bodyText: String {
        get { bodyText_ ?? "Default bodyText" }
        set { bodyText_ = newValue }
    }
    
    var dateCreated: Date {
        get {dateCreated_ ?? Date()}
        set {dateCreated_ = newValue}
    }
    
    // I'm making this public as I'm getting a warning otherwise, but the tutorial tasksexample is not getting this warning
    public var id: UUID {
        #if DEBUG
        id_!
        #else
        id_ ?? UUID()
        #endif
    }
    
    convenience init(title: String, bodyText: String, context: NSManagedObjectContext) {
        self.init(context: context)
        self.title = title
        self.bodyText = bodyText
        
    }
    
    public override func awakeFromInsert() {
        self.id_ = UUID()
        self.dateCreated_ = Date()
        
        // Getting the count of the entities
        guard let context = self.managedObjectContext else { return }
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
        let count = (try? context.count(for: fetchRequest)) ?? 0
        self.num_ = Int32(count)
    }
    
    static func delete(note: Note) {
        guard let context = note.managedObjectContext else {return}
        context.delete(note)
    }
    
    static func fetch (_ predicate: NSPredicate = .all) -> NSFetchRequest<Note> {
        let request = Note.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \Note.num_, ascending: true)]
        
        request.predicate = predicate
        
        return request
    }
    
    
    static var example: Note {
        let context = PersistenceController.preview.container.viewContext
        let note = Note(title: "Example Note", bodyText: "Example body", context: context)
        
        return note
    }
}
