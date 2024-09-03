//
//  CopyNotesApp.swift
//  CopyNotes
//
//  Created by Clive on 27/08/2024.
//

import SwiftUI
import Sparkle

@main
struct CopyNotesApp: App {
    private let updaterController: SPUStandardUpdaterController
    
    let persistentController = PersistenceController.shared
    @Environment(\.scenePhase) var scenePhase
    
    init() {
            // If you want to start the updater manually, pass false to startingUpdater and call .startUpdater() later
            // This is where you can also pass an updater delegate if you need one
            updaterController = SPUStandardUpdaterController(startingUpdater: true, updaterDelegate: nil, userDriverDelegate: nil)
        }
    
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
        .commands {
                    CommandGroup(after: .appInfo) {
                        CheckForUpdatesView(updater: updaterController.updater)
                    }
                }
    }
}
