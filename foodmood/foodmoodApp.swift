//
//  foodmoodApp.swift
//  foodmood
//
//  Created by Dhruv Rasikbhai Jivani on 12/8/25.
//

import SwiftUI
import CoreData

@main
struct foodmoodApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
