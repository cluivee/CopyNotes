//
//  DetailView.swift
//  CopyNotes
//
//  Created by Clive on 28/08/2024.
//

import SwiftUI
import Combine

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
    //    @StateObject private var textObserver: TextFieldObserver
    @StateObject private var textObserver: TextFieldObserver<String>
    
    @Binding var isEditingMode: Bool
    var deleteFunction: () -> Void
    // Storing a bool to detect when the mouse is hovering over a view
    @State private var overText = false
    @State private var alertIsShowing = false
    // Booleans to prevent extra debouncing if we are simply switching notes
    @State private var isNewNoteTitle = false
    @State private var isNewNoteBody = false
    @State private var counter = 0
    
    init(note: Note, isEditingMode: Binding<Bool>, deleteFunction: @escaping () -> Void) {
        self.note = note
        self._isEditingMode = isEditingMode
        self.deleteFunction = deleteFunction
        // Initialising the textObserver with the value of note.title
        _textObserver = StateObject(wrappedValue: TextFieldObserver(initialTitle: note.title, initialBodyText: note.bodyText))
    }
    
    
    var body: some View {
        VStack {
            Text(String(describing: counter))
                Text(String(describing: isNewNoteTitle))
            TextField("Title", text: $textObserver.currentTitle)
                .font(.title.bold())
                .border(.clear)
                .textFieldStyle(PlainTextFieldStyle())
                .padding([.top, .leading], 4)
                .onChange(of: textObserver.debouncedTitle) { val in
                    if !isNewNoteTitle {
                        note.title = val
                        print("Is this working, the title is debouncing: ", val)
                    } else {
                        isNewNoteTitle = false
                    }
                }
                .onChange(of: note) {val in
                    textObserver.currentTitle = val.title
                    isNewNoteTitle = true
                    print("has note changed")
                    // This is where we're saving when the note is changed. Maybe it makes more sense to do this in ContentView but for now it works
                    PersistenceController.shared.save()
                }
            if isEditingMode {
                TextEditor(text: $textObserver.currentBodyText)
                    .font(.title3)
                    .border(.blue)
                    .onChange(of: textObserver.debouncedBodyText) { val in
                        if !isNewNoteBody {
                            note.bodyText = val
                            print("Is this working, the bodyText is debouncing: ", val)
                        } else {
                            isNewNoteBody = false
                        }
                    }
                    .onChange(of: note) {val in
                        textObserver.currentBodyText = val.bodyText
                        isNewNoteBody = true
                        print("has note changed in body")
                        PersistenceController.shared.save()
                    }
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
        .onChange(of: textObserver.debouncedBodyText) {val in
            counter += 1
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
}

private func copyToClipboard(bodyText: String) {
    let pasteboard = NSPasteboard.general
    pasteboard.clearContents()
    pasteboard.setString(bodyText, forType: .string)
    
}


//struct DetailView_Previews: PreviewProvider {
//    static var previews: some View {
//        DetailView()
//    }
//}
