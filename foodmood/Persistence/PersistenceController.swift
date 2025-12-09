//
//  PersistenceController.swift
//  FoodMood
//

internal import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        // Must match your .xcdatamodeld filename exactly
        container = NSPersistentContainer(name: "FoodMoodModel")

        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }

        container.loadPersistentStores { storeDescription, error in
            if let error = error as NSError? {
                fatalError("""
                    Unresolved error \(error), \(error.userInfo)
                    Make sure your model file exists, matches the name, and contains the correct entities.
                    """)
            } else {
                print("✅ Core Data store loaded at: \(storeDescription.url?.absoluteString ?? "Unknown location")")
            }
        }

        // Optional: automatically merge changes from parent context
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
}
