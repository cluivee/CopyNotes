//
//  CopyNotesApp.swift
//  CopyNotes
//
//  Created by Clive on 27/08/2024.
//

import SwiftUI

@main
struct CopyNotesApp: App {
    
    let persistentController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistentController.container.viewContext)
                .onChange(of: scenePhase) { newValue in
                    if newValue == .background {
                        persistentController.save()
                    }
                }
        }
    }
}
