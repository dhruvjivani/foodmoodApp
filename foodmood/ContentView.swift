//
//  ContentView.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import SwiftUI
internal import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    // Fetch all LogEntry objects sorted by date
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntry.date, ascending: false)],
        animation: .default
    )
    private var logEntries: FetchedResults<LogEntry>

    var body: some View {
        NavigationView {
            List {
                ForEach(logEntries) { entry in
                    NavigationLink {
                        // Navigate to DetailView for each entry
                        DetailView(entry: entry)
                    } label: {
                        VStack(alignment: .leading) {
                            Text(entry.wrappedMealName)
                                .font(.headline)
                            Text("\(entry.date ?? Date(), formatter: dateFormatter)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteEntries)
            }
            .navigationTitle("FoodMood Log")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: addEntry) {
                        Label("Add Entry", systemImage: "plus")
                    }
                }
            }

            Text("Select a log entry")
                .foregroundColor(.secondary)
        }
    }

    // Add a new LogEntry
    private func addEntry() {
        withAnimation {
            let newEntry = LogEntry(context: viewContext)
            newEntry.mealName = "New Meal"
            newEntry.mood = Mood.neutral.rawValue
            newEntry.calories = 0
            newEntry.notes = ""
            newEntry.date = Date()

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    // Delete selected LogEntry objects
    private func deleteEntries(offsets: IndexSet) {
        withAnimation {
            offsets.map { logEntries[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

// Date formatter for displaying log entry dates
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .medium
    formatter.timeStyle = .short
    return formatter
}()

#Preview {
    // Use your actual persistence controller
    ContentView().environment(\.managedObjectContext, PersistenceController.shared.container.viewContext)
}
