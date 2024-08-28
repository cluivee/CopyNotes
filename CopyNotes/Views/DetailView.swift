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
            TextEditor(text: $note.bodyText)
                .font(.title3)
            Spacer()
        }
    }
}

//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
