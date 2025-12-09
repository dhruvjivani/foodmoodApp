//
//  LogEntryViewModel.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import Foundation
internal import CoreData
import SwiftUI
import Combine

@MainActor
final class LogEntryViewModel: ObservableObject {
    var objectWillChange = ObservableObjectPublisher()
    
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false

    let context: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.context = context
    }

    func delete(_ entry: LogEntry) {
        context.delete(entry)

        do {
            try context.save()
        } catch {
            errorMessage = "Failed to delete entry."
            showError = true
            print("❌ Delete error: \(error)")
        }
    }

    func deleteFromDetail(_ entry: LogEntry, onComplete: () -> Void) {
        delete(entry)
        onComplete()
    }
}
