//
//  FoodMoodApp.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import SwiftUI
internal import CoreData

@main
struct FoodMoodApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            DailyLogListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
