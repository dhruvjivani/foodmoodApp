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

    // MARK: - Derived stats
    private var totalEntriesToday: Int {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        return entries.filter {
            guard let d = $0.date else { return false }
            return calendar.isDate(d, inSameDayAs: today)
        }.count
    }

    private var mostCommonMood: Mood? {
        let groups = Dictionary(grouping: entries) { $0.wrappedMood }
        let sorted = groups.sorted { $0.value.count > $1.value.count }
        return sorted.first?.key
    }

    var body: some View {
        NavigationView {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(.systemBackground), Color.blue.opacity(0.06)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 16) {

                    // MARK: Header "dashboard" card
                    headerCard
                        .padding(.horizontal)

                    // MARK: Mood filter segmented control
                    filterBar
                        .padding(.horizontal)

                    // MARK: Content list
                    List {
                        ForEach(filteredEntries(), id: \.objectID) { entry in
                            NavigationLink(destination: DetailView(entry: entry)) {
                                LogRowView(entry: entry)
                                    .listRowSeparator(.hidden)
                            }
                            .listRowBackground(Color.clear)
                        }
                        .onDelete(perform: deleteItems)
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                }
            }
            .navigationTitle("FoodMood")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink {
                        AddEntryView()
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                    .accessibilityLabel("Add new entry")
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    NavigationLink(destination: WeeklySummaryView()) {
                        Image(systemName: "chart.bar.doc.horizontal.fill")
                            .font(.title3)
                    }
                    .accessibilityLabel("Weekly summary")
                }
            }
        }
    }

    // MARK: - Header card
    private var headerCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(Date(), style: .date)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("Your day at a glance")
                        .font(.title2)
                        .bold()
                }
                Spacer()
                if let mood = mostCommonMood {
                    VStack(spacing: 4) {
                        Text(mood.emoji)
                            .font(.largeTitle)
                        Text("Most common mood")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                    .padding(10)
                    .background(.ultraThickMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                }
            }

            HStack(spacing: 12) {
                statPill(
                    title: "Today’s logs",
                    value: "\(totalEntriesToday)"
                )
                statPill(
                    title: "Total entries",
                    value: "\(entries.count)"
                )
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(
                    LinearGradient(
                        colors: [Color.blue.opacity(0.15), Color.purple.opacity(0.18)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
        .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 6)
    }

    private func statPill(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .padding(10)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14))
    }

    // MARK: - Filter segmented control
    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(0..<filterOptions.count, id: \.self) { index in
                    let isSelected = filterIndex == index
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.85)) {
                            filterIndex = index
                        }
                    } label: {
                        Text(filterOptions[index])
                            .font(.subheadline)
                            .padding(.vertical, 6)
                            .padding(.horizontal, 12)
                            .background(
                                Capsule().fill(
                                    isSelected
                                    ? Color.accentColor
                                    : Color(.secondarySystemBackground)
                                )
                            )
                            .foregroundColor(isSelected ? .white : .primary)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    // MARK: - Filtering
    private func filteredEntries() -> [LogEntry] {
        guard filterIndex > 0 else { return Array(entries) }
        let mood = Mood.allCases[filterIndex - 1]
        return entries.filter { $0.mood == mood.rawValue }
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
