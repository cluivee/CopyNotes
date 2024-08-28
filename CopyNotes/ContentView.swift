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
                List() {
                    ForEach(notes) {note in
                        Button(action: {
                            selectedNote = note
                            copyToClipboard(bodyText: note.bodyText)
                        }) {
                            NoteRowView(note: note, selectedNote: $selectedNote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(5)
                                
                            
                        }
                       
                        .buttonStyle(BlueButtonStyle())
                    }
                    
                }
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
    
    // MARK: functions:
    private func copyToClipboard(bodyText: String) {
        if bodyText != nil {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(bodyText, forType: .string)
        }
    }
    
    private func addNote() {
        if notes.count < 6 {
            let newNote = Note(title: "New Title", bodyText: "New bodyText", context: context)
            selectedNote = newNote
            PersistenceController.shared.save()
        }
        
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

