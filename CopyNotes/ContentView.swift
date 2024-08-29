//
//  ContentView.swift
//  CopyNotes
//
//  Created by Clive on 27/08/2024.
//

import SwiftUI

struct ContentView: View {
    
    @Environment(\.managedObjectContext) var context
    @FetchRequest(fetchRequest: Note.fetch(), animation: .default)
    var notes: FetchedResults<Note>
    
    @State private var selectedNote: Note?
    @State private var searchText = ""
    
    
    var body: some View {
        NavigationView  {
            VStack{
                SearchBar()
                // In the context of enumerated, the enumerated method turns an array of elements into an array of tuples. The '1' part is the second part of the tuple, which is the element itself
                List() {
                    ForEach(Array(notes.enumerated()), id: \.1.id) {num, note in
                        Button(action: {
                            selectedNote = note
                            copyToClipboard(bodyText: note.bodyText)
                        }) {
                            NoteRowView(note: note, num: note.num, selectedNote: $selectedNote)
                        }
                        .buttonStyle(BlueButtonStyle())
                        .contextMenu {
                            Button(action: {
                                deleteSelectedNote(deletedNote: note)
                            }){
                                Text("Delete")
                            }
                        }
                    }.onMove(perform: moveNotes)
                    
                }
                .frame(minWidth: 250, maxWidth: 350)
                .toolbar {
                    ToolbarItemGroup {
                        Spacer()
                        Button(action: {
                            addNote()
                        }) {
                            Image(systemName: "plus")
                                .resizable()
                                .frame(width: 24.0, height: 24.0)
                        }
                    }
                }
                
                Text(String(describing: selectedNote))
            }
            
            if let selected = selectedNote {
                DetailView(note: selected, deleteFunction: {deleteSelectedNote(deletedNote: selected)})
            } else {
                Text("No note selected")
                    .padding()
            }
            
        }
        
    }
    
    // MARK: functions:
    private func copyToClipboard(bodyText: String) {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(bodyText, forType: .string)
        
    }
    
    private func addNote() {
        if notes.count < 6 {
            let newNote = Note(title: "New Title", bodyText: "New bodyText", context: context)
            selectedNote = newNote
            PersistenceController.shared.save()
        }
        
    }
    
    private func deleteSelectedNote(deletedNote: Note) {
        context.delete(deletedNote)
        
        // These two lines are just to create another array, so we can filter through that array and remove the deleted note, as we don't seem to be able to use array methods (such as .remove) on the fetchedResults directly
        var revisedNotes = notes.map{ $0 }
        
        if let idx = revisedNotes.firstIndex(where: { $0 === deletedNote }) {
            revisedNotes.remove(at: idx)
        }
        
        for (index, note) in revisedNotes.enumerated() {
            note.num = index + 1
        }
        PersistenceController.shared.save()
    }
    
    private func moveNotes(from source: IndexSet, to destination: Int) {
        // Make an array of items from fetched results
//        var revisedNotes = notes.sorted { $0.num < $1.num }
        var revisedNotes = notes.map{ $0 }
        
        // This line moves the item. The IndexSet contains all the items that are to be moved (usually just one item), and the destination (an Int) contains the position where it will be moved to
        revisedNotes.move(fromOffsets: source, toOffset: destination)
        
        // renumber in reverse order to minimise changes to the indices
        for reverseIndex in stride(from: revisedNotes.count - 1, through: 0, by: -1 )
            {revisedNotes[reverseIndex].num = reverseIndex + 1}
        
        PersistenceController.shared.save()
        
    }
    
}


struct BlueButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .foregroundColor(configuration.isPressed ? Color.blue : Color.white)
            .background(configuration.isPressed ? Color.white : Color.blue)
            .cornerRadius(6.0)
            .padding(1)
    }
}




struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

