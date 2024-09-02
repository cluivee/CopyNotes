//
//  DetailView.swift
//  CopyNotes
//
//  Created by Clive on 28/08/2024.
//

import SwiftUI
import Combine

// This is just to make the texteditor background transparent. This sets all TextViews background to .clear
extension NSTextView {
    open override var frame: CGRect {
        didSet {
            backgroundColor = .clear //<<here clear
            drawsBackground = true
        }

    }
}




struct DetailView: View {
    @Environment(\.managedObjectContext) var context
    
    @ObservedObject var note: Note
    
    @StateObject private var textObserver: TextFieldObserver<String>
    
    @Binding var isEditingMode: Bool
    var deleteFunction: () -> Void
    // Storing a bool to detect when the mouse is hovering over a view
    @State private var overText = false
    @State private var charAlertShowing = false
    // Booleans to prevent extra debouncing if we are simply switching notes
    @State private var isNewNoteTitle = false
    @State private var isNewNoteBody = false
    @State private var counter = 0
    
    // max number of characters in the texteditor
    let charLimit = 10000
    
    init(note: Note, isEditingMode: Binding<Bool>, deleteFunction: @escaping () -> Void) {
        self.note = note
        self._isEditingMode = isEditingMode
        self.deleteFunction = deleteFunction
        // Initialising the textObserver with the value of note.title
        _textObserver = StateObject(wrappedValue: TextFieldObserver(initialTitle: note.title, initialBodyText: note.bodyText))
    }
    
    
    var body: some View {
        VStack {
            TextField("Title", text: $textObserver.currentTitle)
                .font(.title.bold())
            // adding padding of 8 everywhere just so the borders have better spacing
                .padding(8)
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
            
            if isEditingMode {
                TextEditor(text: $textObserver.currentBodyText)
                    .font(.title3)
                    .padding(8)
                    .onChange(of: textObserver.debouncedBodyText) { val in
                        if !isNewNoteBody {
                            note.bodyText = val
                            print("Is this working, the bodyText is debouncing: ", val)
                        } else {
                            isNewNoteBody = false
                        }
                    }
                    .onReceive(Just(textObserver.currentBodyText)) { _ in
                        limitText(charLimit)
                    }
            } else {
                ScrollView{
                    Text(note.bodyText)
                        .padding(.leading, 5)
                        .padding(.trailing, 18)
                        .padding(5)
                        .font(.title3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .onHover { over in
                            overText = over
                        }
                        .overlay(
                            RoundedRectangle(cornerRadius: 5)
                                .stroke(overText ? Color("orangeBorderColor") : Color.accentColor, lineWidth: 3)
                        )
                        .background(Color.black)
                        .foregroundColor(overText ? Color("whiteTextColor"): .primary)
                        .padding(3)
                        .onTapGesture(){
                            copyToClipboard(bodyText: note.bodyText)
                        }
                    
                    
                }
            }
        }
        .onChange(of: note) {val in
            textObserver.currentTitle = val.title
            textObserver.currentBodyText = val.bodyText
            isNewNoteTitle = true
            isNewNoteBody = true
            print("has note changed")
            // This is where we're saving when the note is changed. Maybe it makes more sense to do this in ContentView but for now it works
            PersistenceController.shared.save()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(EdgeInsets(top: 20, leading: 45, bottom: 20, trailing: 45))
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
                .foregroundColor(Color("highlightYellow"))
                Button("Copy") {copyToClipboard(bodyText: note.bodyText)}
                .foregroundColor(Color("highlightYellow"))
                // Ok So apparently this was messing up the spacer in the sidebar
                //                Spacer().frame(width: 50)
                Button("Delete") {deleteFunction()}
                .foregroundColor(Color("highlightYellow"))
            }
            
        }
        .alert(isPresented: $charAlertShowing) {
            // single button Alert
            Alert(title: Text("Maximum number of characters is 10,000"))
        }
        
    }
    
    // function to limit text length
    func limitText(_ upper: Int) {
        if textObserver.currentBodyText.count > upper {
            textObserver.currentBodyText = String(textObserver.currentBodyText.prefix(upper))
            charAlertShowing.toggle()
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
