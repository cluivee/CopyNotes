//
//  TextFieldObserver.swift
//  CopyNotes
//
//  Created by Clive on 30/08/2024.
//

import Foundation
import Combine
import SwiftUI

class TextFieldObserver<Value>: ObservableObject {
    @Published var currentTitle: Value
    @Published var debouncedTitle: Value
    
    @Published var currentBodyText: Value
    @Published var debouncedBodyText: Value
    
    init(initialTitle: Value, initialBodyText: Value, delay: Double = 1.0) {
        
        // careful here, the first "initialValue" is a parameter of Published, the value after that is the parameter "initalValue" from the initialiser. This is why it is really confusing when people call variables the same as actual parameters
        
        _currentTitle = Published(initialValue: initialTitle)
        _debouncedTitle = Published(initialValue: initialTitle)
        
        _currentBodyText = Published(initialValue: initialBodyText)
        _debouncedBodyText = Published(initialValue: initialBodyText)
        
        $currentTitle
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .assign(to: &$debouncedTitle)
        $currentBodyText
            .debounce(for: .seconds(delay), scheduler: RunLoop.main)
            .assign(to: &$debouncedBodyText)
    }
}

//
//class TextFieldObserver : ObservableObject {
//    @Published var currentTitle: String
//    @Published var debouncedTitle: String
//
//    init(initialTitle: String, delay: Double = 0.3) {
//        _currentTitle = Published(initialTitle: initialTitle)
//        _debouncedTitle = Published(initialTitle: initialTitle)
//        $currentTitle
//            .sink {value in
//                self.debouncedTitle = value
//
//            }
//
//    }
//
    
//    @Published var currentBodyText: String
//    @Published var debouncedBodyText: String
    
//    init(initialTitle: String) {
//
//        _currentTitle = Published(initialTitle: initialTitle)
//        _debouncedTitle = Published(initialTitle: initialTitle)
//        _currentBodyText = Published(initialBodyText: initialBodyText)
//        _debouncedBodyText = Published(initialBodyText: initialBodyText)
//        $currentTitle
//            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
//            .assign(to: &$debouncedTitle)
//        $currentBodyText
//            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
//            .assign(to: &$debouncedBodyText)
//    }
//}
