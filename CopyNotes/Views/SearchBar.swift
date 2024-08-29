//
//  SearchBar.swift
//  CopyNotes
//
//  Created by Clive on 28/08/2024.
//

import SwiftUI


struct SearchBar: View {
    
    @Binding var searchText: String
    
    var body: some View {
        TextField("Search", text: $searchText)
            .textFieldStyle(RoundedBorderTextFieldStyle())
            .padding()

    }
}

struct SearchBar_Previews: PreviewProvider {
    static var previews: some View {
        SearchBar(searchText: .constant(""))
    }
}
