//
//  AddEntryViewModel.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import Foundation
import SwiftUI
internal import CoreData
import Combine

final class AddEntryViewModel: ObservableObject {
    // MARK: - Published properties (bound to the UI)
    @Published var mealName: String = ""
    @Published var selectedMood: Mood = .neutral
    @Published var calories: Int = 0
    @Published var notes: String = ""
    @Published var photoData: Data? = nil
    @Published var aiPrediction: String = ""
    @Published var showValidationAlert: Bool = false
    @Published var validationMessage: String = ""

    // MARK: - Initializer
    // Default, accessible initializer so AddEntryViewModel() works
    init() {}

    // MARK: - Validation
    var saveDisabled: Bool {
        mealName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || calories < 0
    }

    func validateBeforeSave() -> Bool {
        if mealName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            validationMessage = "Please enter the meal name."
            showValidationAlert = true
            return false
        }
        if calories < 0 {
            validationMessage = "Calories cannot be negative."
            showValidationAlert = true
            return false
        }
        return true
    }

    // MARK: - Save to Core Data
    func save(in context: NSManagedObjectContext) throws {
        guard validateBeforeSave() else {
            throw NSError(domain: "validation", code: 1)
        }

        let newEntry = LogEntry(context: context)

        // Do NOT set newEntry.id (it's a Core Data ObjectID)
        newEntry.mealName = mealName.trimmingCharacters(in: .whitespacesAndNewlines)
        newEntry.mood = selectedMood.rawValue
        newEntry.calories = Int64(Int16(calories))
        newEntry.notes = notes
        newEntry.date = Date()
        newEntry.aiPrediction = aiPrediction

        if let data = photoData {
            // This assumes your Core Data model has a Binary Data field "photo"
            newEntry.photo = data
        }

        try context.save()
    }
}
