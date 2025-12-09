//
//  FileExportManager.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

//import Foundation
//import UIKit
//internal import CoreData
//
//final class FileExportManager {
//
//    static let shared = FileExportManager()
//
//    private init() {}
//
//    /// Saves a LogEntry to a .txt file in the app's documents directory
//    func export(entry: LogEntry) throws -> URL {
//
//        let fileName = formattedFileName(from: entry.date ?? Date())
//        let fileURL = getDocumentsDirectory().appendingPathComponent(fileName)
//
//        let textContent = buildText(from: entry)
//
//        do {
//            try textContent.write(to: fileURL, atomically: true, encoding: .utf8)
//            return fileURL
//        } catch {
//            throw NSError(
//                domain: "FileExport",
//                code: 1,
//                userInfo: [NSLocalizedDescriptionKey: "Failed to save text file."]
//            )
//        }
//    }
//
//    /// Creates a readable .txt representation of a log entry
//    private func buildText(from entry: LogEntry) -> String {
//
//        let dateString = DateFormatter.exportFormatter.string(from: entry.date ?? Date())
//
//        return """
//        FoodMood Entry — \(dateString)
//        ------------------------------
//
//        Meal Name: \(entry.wrappedMealName)
//        Mood: \(entry.wrappedMood)
//        Calories: \(entry.calories)
//
//        AI Prediction: \(entry.wrappedAIPrediction)
//
//        Notes:
//        \(entry.wrappedNotes)
//
//        """
//    }
//
//    /// Example: 2025-12-04_FoodMood.txt
//    private func formattedFileName(from date: Date) -> String {
//        let dateStr = DateFormatter.exportFormatter.string(from: date)
//        return "\(dateStr)_FoodMood.txt"
//    }
//
//    /// Get the app's documents directory path
//    private func getDocumentsDirectory() -> URL {
//        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//    }
//}


import Foundation
import UIKit

struct FileExportManager {
    static func export(entry: LogEntry) throws -> URL {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: entry.date ?? Date())
        let filename = "\(dateString)_FoodMood.txt"
        let text = """
        Date: \(dateString)
        Meal: \(entry.mealName ?? "Unknown")
        Mood: \(entry.mood ?? "Unknown")
        Calories: \(entry.calories)
        AI Prediction: \(entry.aiPrediction ?? "")
        Notes:
        \(entry.notes ?? "")
        """
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let fileURL = dir.appendingPathComponent(filename)
        try text.write(to: fileURL, atomically: true, encoding: .utf8)
        return fileURL
    }

    static func share(url: URL) -> UIActivityViewController {
        return UIActivityViewController(activityItems: [url], applicationActivities: nil)
    }
}
