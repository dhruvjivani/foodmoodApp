//
//  LogEntry+Extensions.swift.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import UIKit
internal import CoreData

extension LogEntry {

    var uiImage: UIImage? {
        guard let data = photo else { return nil }
        return UIImage(data: data)
    }

    var wrappedMealName: String { mealName ?? "" }
    var wrappedMood: Mood { Mood(rawValue: mood ?? "") ?? .neutral }
    var wrappedAIPrediction: String { aiPrediction ?? "" }
    var wrappedNotes: String { notes ?? "" }

    func safeDelete(context: NSManagedObjectContext) {
        context.delete(self)
        do {
            try context.save()
        } catch {
            print("❌ Failed to delete entry: \(error.localizedDescription)")
        }
    }
}
