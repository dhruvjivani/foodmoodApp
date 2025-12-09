//
//  LogRowView.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import SwiftUI
internal import CoreData

struct LogRowView: View {
    @ObservedObject var entry: LogEntry

    var body: some View {
        HStack(spacing: 12) {
            if let data = entry.photo, let ui = UIImage(data: data) {
                Image(uiImage: ui)
                    .resizable()
                    .frame(width: 60, height: 60)
                    .scaledToFill()
                    .cornerRadius(8)
                    .accessibilityLabel("Meal photo row")
                    .accessibilityAddTraits(.isImage)
            } else {
                Rectangle()
                    .fill(Color.secondary.opacity(0.2))
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(entry.mealName ?? "Meal")
                    .font(.headline)
                Text(entry.mood ?? "Unknown")
                    .font(.subheadline)
                Text("\(entry.calories) cal")
                    .font(.subheadline)
            }
            Spacer()
            Text(entry.date ?? Date(), style: .date)
                .font(.caption)
        }
        .padding(.vertical, 8)
    }
}
