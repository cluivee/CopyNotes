//
//  CopyNotesTests.swift
//  CopyNotesTests
//
//  Created by Clive on 27/08/2024.
//

import XCTest
import CoreData
@testable import CopyNotes

class CopyNotesTests: XCTestCase {
    
    var persistenceController: PersistenceController!
    var context: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        // Creating an in-memory persistence container to avoid using the actual database. Otherwise, tests couldn't be considered isolated since one test may overwrite the contents of another test. Also the tests aren't repeatable if the data is saved to disk, as the data in the database might grow over time and the state of the environment might be different on each test run.
        
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
    }
    
    func testCreateNote() throws {
        
        let note = Note(title: "Testing Note", bodyText: "Test Body", context: context)
        
        // Save the note
        persistenceController.save()
        
        // Fetch the note to verify it was created
        let fetchRequest: NSFetchRequest<Note> = Note.fetch()
        
        let notes = try context.fetch(fetchRequest)
        
        XCTAssertEqual(notes.count, 1, "1 note in database")
        XCTAssertEqual(notes.first?.title, "Testing Note", "The title should match")
        XCTAssertEqual(notes.first?.bodyText, "Test Body", "The body text should match")
    }
    
    func testDeleteNote() throws {
        // Create and save a new note
        let note = Note(title: "To Delete", bodyText: "This note will be deleted", context: context)
        persistenceController.save()
        
        // Fetch to make sure it exists
        var fetchRequest: NSFetchRequest<Note> = Note.fetch()
        var notes = try context.fetch(fetchRequest)
        XCTAssertEqual(notes.count, 1, "Should have 1 note before deletion")
        
        // Delete the note
        context.delete(note)
        persistenceController.save()
        
        // Fetch again to ensure it was deleted
        fetchRequest = Note.fetch()
        notes = try context.fetch(fetchRequest)
        XCTAssertEqual(notes.count, 0, "Should have 0 notes after deletion")
    }
    
    func testFetchNotes() throws {
        // example to test
        for i in 1...3 {
            _ = Note(title: "Note \(i)", bodyText: "Body \(i)", context: context)
        }
        persistenceController.save()
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetch()
        let notes = try context.fetch(fetchRequest)
        
        XCTAssertEqual(notes.count, 3, "Should have 3 notes fetched")
    }
    
    func testSavePerformance() throws {
        measure {
            // Measure time taken to create and save a note
            for _ in 0..<100 {
                let note = Note(title: "Performance Test Note", bodyText: "Body", context: context)
                context.insert(note)
            }
            persistenceController.save()
        }
    }
    

}
