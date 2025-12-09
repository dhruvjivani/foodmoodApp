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
        ZStack {
            RoundedRectangle(cornerRadius: 18)
                .fill(.ultraThinMaterial)
                .shadow(color: Color.black.opacity(0.06), radius: 8, x: 0, y: 4)

            HStack(spacing: 12) {
                // Left: image or placeholder
                if let image = entry.uiImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 54, height: 54)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .accessibilityLabel("Meal photo")
                        .accessibilityAddTraits(.isImage)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 14)
                            .fill(Color(.tertiarySystemFill))
                            .frame(width: 54, height: 54)
                        Image(systemName: "fork.knife.circle")
                            .font(.system(size: 22))
                            .foregroundColor(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(entry.wrappedMealName.isEmpty ? "Meal" : entry.wrappedMealName)
                            .font(.headline)
                            .lineLimit(1)
                        Spacer()
                        Text(entry.wrappedMood.emoji)
                            .font(.title3)
                    }

                    HStack(spacing: 6) {
                        Text(entry.wrappedMood.displayName)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("• \(entry.calories) kcal")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    if let date = entry.date {
                        Text(DateFormatter.displayFormatter.string(from: date))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
        }
        .padding(.vertical, 4)
    }
}
