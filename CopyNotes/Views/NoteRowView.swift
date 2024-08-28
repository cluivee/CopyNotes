//
//  NoteRowView.swift
//  CopyNotes
//
//  Created by Clive on 28/08/2024.
//

import SwiftUI

struct NoteRowView: View {
    
    var note : Note
    @Binding var selectedNote: Note?
    
    var body: some View {
        
        Button(action: {
            selectedNote = note
            copyToClipboard(bodyText: note.bodyText)
        }) {VStack(alignment: .leading, spacing: 5) {
            Text("\(note.num). \(note.title)")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.secondary)
            Text(note.bodyText)
                .fontWeight(.light)
                .truncationMode(.tail)
        }.multilineTextAlignment(.leading)
            
        }
        // bluebuttonstyle really is crucial to allow the button to fill the frame, in fact it has to be called in both this view, and also in the contentview to allow the frame modifiers to work now
        .buttonStyle(BlueButtonStyle())
       
    }
    
    private func copyToClipboard(bodyText: String) {
        if bodyText != nil {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(bodyText, forType: .string)
        } else {
            print("selected Index is nil" )
        }
    }
    
}



//struct NoteRowView_Previews: PreviewProvider {
//    static var previews: some View {
//        NoteRowView(note: Note.example, selectedNote: Note.example)
//    }
//}
