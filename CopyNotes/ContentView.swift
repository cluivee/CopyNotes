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
                Text(String(describing: selectedNote))
                
                // In the context of enumerated, the enumerated method turns an array of elements into an array of tuples. The '1' part is the second part of the tuple, which is the element itself
                List() {
                    ForEach(Array(notes.enumerated()), id: \.1.id) {num, note in
                        Button(action: {
                            selectedNote = note
                            copyToClipboard(bodyText: note.bodyText)
                        }) {
                            NoteRowView(note: note, num: num, selectedNote: $selectedNote)
                        }
                        .buttonStyle(BlueButtonStyle())
                        .contextMenu {
                            Button(action: {
                                deleteSelectedNote(deletedNote: note)
                            }){
                                Text("Delete")
                            }
                        }
                    }
                    
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

