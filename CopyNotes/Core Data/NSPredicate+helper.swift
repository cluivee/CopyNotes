//
//  NSPredicate+helper.swift
//  CopyNotes
//
//  Created by Clive on 28/08/2024.
//

import Foundation

// All this extension does is allow us to fetch all of the values. There is almost certainly a way to do this without using a helper

extension NSPredicate {
    static let all = NSPredicate(format: "TRUEPREDICATE")
    static let none = NSPredicate(format: "FALSEPREDICATE")
}
