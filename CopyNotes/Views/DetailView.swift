//
//  DetailView.swift
//  CopyNotes
//
//  Created by Clive on 28/08/2024.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var note: Note
    var deleteFunction: () -> Void
    
    var body: some View {
        VStack {
            TextField("Title", text: $note.title)
                .font(.title.bold())
                .border(.clear)
                .textFieldStyle(PlainTextFieldStyle())
                .padding([.top, .leading], 4)
            TextEditor(text: $note.bodyText)
                .font(.title3)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 50))
        .toolbar {
            ToolbarItemGroup{
                Button("Edit") {}
                Button("Save") {}
                Button("Copy") {copyToClipboard(bodyText: note.bodyText)}
                // Ok So apparently this was messing up the spacer in the sidebar
                //                Spacer().frame(width: 50)
                Button("Delete") {deleteFunction()}
            }
        }
    }
    
    private func copyToClipboard(bodyText: String) {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.setString(bodyText, forType: .string)
    
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
