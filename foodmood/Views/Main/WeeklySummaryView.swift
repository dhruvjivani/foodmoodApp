//
//  WeeklySummaryView.swift
//  foodmood
//
//  Created by Dhruv Rasikbhai Jivani on 12/8/25.
//

import SwiftUI
import Charts
internal import CoreData

struct WeeklySummaryView: View {
    @FetchRequest(
        entity: LogEntry.entity(),
        sortDescriptors: [NSSortDescriptor(keyPath: \LogEntry.date, ascending: false)],
        animation: .default
    ) var entries: FetchedResults<LogEntry>

    var grouped: [(String, Int)] {
        let calendar = Calendar.current
        let startOfWeek = calendar.date(byAdding: .day, value: -7, to: Date())!

        let recent = entries.filter { $0.date ?? Date() >= startOfWeek }

        let counts = Dictionary(grouping: recent, by: { $0.mood ?? "Unknown" })
            .map { ($0.key, $0.value.count) }

        return counts.sorted { $0.0 < $1.0 }
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text("Weekly Mood Summary")
                .font(.title2)
                .bold()

            Chart(grouped, id: \.0) { mood, count in
                BarMark(
                    x: .value("Mood", mood),
                    y: .value("Entries", count)
                )
            }
            .frame(height: 250)
        }
        .padding()
    }
}
