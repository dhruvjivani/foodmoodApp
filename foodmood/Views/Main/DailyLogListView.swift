import SwiftUI
internal import CoreData

struct DailyLogListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntry.date, ascending: false)],
        animation: .default
    )
    private var entries: FetchedResults<LogEntry>

    // 0 = All, 1... = each Mood in Mood.allCases
    @State private var filterIndex: Int = 0

    private var filterOptions: [String] {
        ["All"] + Mood.allCases.map { $0.displayName }
    }

    var body: some View {
        NavigationView {
            VStack {
                // MARK: Mood Filter
                QuoteBannerView()
                    .padding(.horizontal)
                HStack {
                    Text("Filter by mood:")
                        .font(.body)

                    Picker("Mood Filter", selection: $filterIndex) {
                        ForEach(0..<filterOptions.count, id: \.self) { index in
                            Text(filterOptions[index])
                                .tag(index)
                        }
                    }
                    .pickerStyle(.menu)
                }
                .padding([.top, .horizontal])

                // MARK: List of entries
                List {
                    ForEach(filteredEntries(), id: \.objectID) { entry in
                        NavigationLink(destination: DetailView(entry: entry)) {
                            LogRowView(entry: entry)
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .listStyle(.plain)
            }
            .navigationTitle("Daily Logs")
            .toolbar {
                // Add entry
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddEntryView()
                    } label: {
                        Image(systemName: "plus")
                    }
                    .accessibilityLabel("Add new entry")
                }

                // Weekly summary
                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: WeeklySummaryView()) {
                        Image(systemName: "chart.bar")
                    }
                    .accessibilityLabel("Weekly summary")
                }
            }
        }
    }

    // MARK: - Filtering
    private func filteredEntries() -> [LogEntry] {
        // 0 = All moods
        guard filterIndex > 0 else {
            return Array(entries)
        }

        let mood = Mood.allCases[filterIndex - 1]
        return entries.filter { entry in
            entry.mood == mood.rawValue
        }
    }

    // MARK: - Delete
    private func deleteItems(offsets: IndexSet) {
        let current = filteredEntries()

        withAnimation {
            offsets.forEach { index in
                let entry = current[index]
                viewContext.delete(entry)
            }
            do {
                try viewContext.save()
            } catch {
                print("Delete error: \(error)")
            }
        }
    }
}
