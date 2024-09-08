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
    var backgroundContext: NSManagedObjectContext!
    
    override func setUpWithError() throws {
        // Creating an in-memory persistence container to avoid using the actual database. Otherwise, tests couldn't be considered isolated since one test may overwrite the contents of another test. Also the tests aren't repeatable if the data is saved to disk, as the data in the database might grow over time and the state of the environment might be different on each test run.
        
        persistenceController = PersistenceController(inMemory: true)
        context = persistenceController.container.viewContext
        backgroundContext = persistenceController.container.newBackgroundContext()
        
    }
    
    override func tearDownWithError() throws {
        persistenceController = nil
        context = nil
        backgroundContext = nil
    }
    
    func testAddNote() throws {
        
        let note = Note(title: "Testing Note", bodyText: "Test Body", context: context)
        
        persistenceController.save()
        
        // Fetching the note to verify it was created
        let fetchRequest: NSFetchRequest<Note> = Note.fetch()
        
        let notes = try context.fetch(fetchRequest)
        
        XCTAssertEqual(notes.count, 1, "1 note in database")
        XCTAssertEqual(notes.first?.title, "Testing Note", "The title should match")
        XCTAssertEqual(notes.first?.bodyText, "Test Body", "The body text should match")
        XCTAssertNotNil(notes.first?.id, "id should have a value")
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
    
    
    func testRootContextIsSavedAfterAddingReport() {
        
        // Create an expectation for a background context save notification
        let expectation = self.expectation(description: "Background context save")
        
        // add observer for that notification
        NotificationCenter.default.addObserver(forName: .NSManagedObjectContextDidSave, object: backgroundContext, queue: .main) { _ in
            expectation.fulfill()
        }
        
        // Adding a new note in the background context. Perform asynchoronously performs the closure on the context's queue
        backgroundContext.perform {
            let newNote = Note(context: self.backgroundContext)
            newNote.title = "Test Title"
            newNote.bodyText = "Test note body"
            do {
                try self.backgroundContext.save()
            } catch {
                XCTFail("Failed to save background context: \(error)")
            }
        }
        
        // Wait for the expectation to be fulfilled or timeout after 2 seconds
        waitForExpectations(timeout: 2) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }
    
    
    func testFetchNotes() throws {
        // example 3 notes to test
        for i in 1...3 {
                    _ = Note(title: "Note \(i)", bodyText: "Body \(i)", context: context)
                }
        persistenceController.save()
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetch()
        let notes = try context.fetch(fetchRequest)
        
        XCTAssertNotNil(notes)
        XCTAssertEqual(notes.count, 3, "Should have 3 notes fetched")
    }
    
    
    func testUpdateNotes() throws {
        let updatingTestNote = Note(title: "Initial title", bodyText: "Initial Text",  context: context)
        
        updatingTestNote.title = "Updated title"
        updatingTestNote.bodyText = "Updated text"
        
        persistenceController.save()
        
        let fetchRequest: NSFetchRequest<Note> = Note.fetch()
        let notes = try context.fetch(fetchRequest)
        
        // Asserting that the new note id maches the old one
        XCTAssertTrue(notes.first?.id == updatingTestNote.id)
        XCTAssertTrue(notes.first?.title == "Updated title")
        XCTAssertTrue(notes.first?.bodyText == "Updated text")
    }
    
    
    
}
