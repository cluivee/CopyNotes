//
//  DetailView.swift
//  CopyNotes
//
//  Created by Clive on 28/08/2024.
//

import SwiftUI


// This is just to make the texteditor background transparent. This sets all TextViews background to .clear
//extension NSTextView {
//    open override var frame: CGRect {
//        didSet {
//            backgroundColor = .clear //<<here clear
//            drawsBackground = true
//        }
//
//    }
//}


struct DetailView: View {
    @Environment(\.managedObjectContext) var context
    @ObservedObject var note: Note
    @Binding var isEditingMode: Bool
    var deleteFunction: () -> Void
    // Storing a bool to detect when the mouse is hovering over a view
    @State private var overText = false
    @State private var alertIsShowing = false
    
    var body: some View {
        VStack {
            TextField("Title", text: $note.title)
                .font(.title.bold())
                .border(.clear)
                .textFieldStyle(PlainTextFieldStyle())
                .padding([.top, .leading], 4)
            
            if isEditingMode {
                TextEditor(text: $note.bodyText)
                    .font(.title3)
                    .border(.blue)
            } else {
                ScrollView{
                    Text(note.bodyText)
                        .padding(.leading, 5)
                        .padding(.trailing, 18)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onHover { over in
                            overText = over
                        }
                        .border(overText ? .green: .blue)
                }
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 20, leading: 50, bottom: 20, trailing: 50))
        .toolbar {
            ToolbarItemGroup{
                Button(action: {
                    if isEditingMode {
                        isEditingMode.toggle()
                        PersistenceController.shared.save()
                    } else {
                        isEditingMode.toggle()
                    }}
                )
                {
                    Text("Edit Mode")
                        .hidden()
                        .overlay(Text(isEditingMode ? "Save" : "Edit Mode"))
                }
                .buttonStyle(BorderedButtonStyle())
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
