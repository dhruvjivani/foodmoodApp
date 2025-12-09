import SwiftUI
internal import CoreData

struct DetailView: View {
    @ObservedObject var entry: LogEntry
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var showingDeleteConfirm = false
    @State private var showingShare = false
    @State private var exportURL: URL?
    @State private var showExportErrorAlert = false

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {

                // MARK: Hero image
                if let image = entry.uiImage {
                    ZStack(alignment: .bottomLeading) {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFill()
                            .frame(height: 220)
                            .clipped()

                        LinearGradient(
                            colors: [.black.opacity(0.0), .black.opacity(0.6)],
                            startPoint: .center,
                            endPoint: .bottom
                        )

                        VStack(alignment: .leading, spacing: 4) {
                            Text(entry.wrappedMealName.isEmpty ? "Meal" : entry.wrappedMealName)
                                .font(.title)
                                .bold()
                                .foregroundColor(.white)

                            HStack(spacing: 8) {
                                Text(entry.wrappedMood.emoji)
                                Text(entry.wrappedMood.displayName)
                            }
                            .foregroundColor(.white.opacity(0.9))
                        }
                        .padding()
                    }
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(LinearGradient(
                                colors: [Color.orange.opacity(0.3), Color.red.opacity(0.3)],
                                startPoint: .top,
                                endPoint: .bottom
                            ))
                            .frame(height: 180)

                        VStack(spacing: 8) {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                            Text(entry.wrappedMealName.isEmpty ? "Meal" : entry.wrappedMealName)
                                .font(.title2)
                                .bold()
                        }
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal)
                }

                // MARK: Info cards
                VStack(spacing: 12) {
                    // Date & calories
                    infoCard(
                        title: "Overview",
                        icon: "calendar",
                        content: {
                            VStack(alignment: .leading, spacing: 4) {
                                if let d = entry.date {
                                    Text("Date: \(DateFormatter.displayFormatter.string(from: d))")
                                }
                                Text("Calories: \(entry.calories) kcal")
                                Text("Mood: \(entry.wrappedMood.displayName)")
                            }
                            .font(.body)
                        }
                    )

                    // AI prediction
                    if let prediction = entry.aiPrediction, !prediction.isEmpty {
                        infoCard(
                            title: "AI Prediction",
                            icon: "sparkles",
                            content: {
                                Text(prediction)
                                    .font(.body)
                            }
                        )
                    }

                    // Notes
                    if let notes = entry.notes,
                       !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        infoCard(
                            title: "Notes",
                            icon: "note.text",
                            content: {
                                Text(notes)
                                    .font(.body)
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        )
                    }
                }
                .padding(.horizontal)

                Spacer().frame(height: 20)
            }
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Entry Details")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Button {
                        exportEntry()
                    } label: {
                        Label("Export", systemImage: "square.and.arrow.up")
                    }

                    Button(role: .destructive) {
                        showingDeleteConfirm = true
                    } label: {
                        Label("Delete", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .font(.title2)
                }
                .accessibilityLabel("More options")
            }
        }
        .sheet(isPresented: $showingShare) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            } else {
                Text("Nothing to share.")
            }
        }
        .alert("Export Failed", isPresented: $showExportErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Unable to export this entry.")
        }
        .confirmationDialog(
            "Are you sure you want to delete this entry?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) { }
        }
    }

    // MARK: - Helpers

    private func infoCard<Content: View>(
        title: String,
        icon: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(title, systemImage: icon)
                    .font(.headline)
                Spacer()
            }
            content()
        }
        .padding()
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 18))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 3)
    }

    private func exportEntry() {
        do {
            let url = try FileExportManager.export(entry: entry)
            exportURL = url
            showingShare = true
        } catch {
            showExportErrorAlert = true
        }
    }

    private func deleteEntry() {
        viewContext.delete(entry)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Error deleting entry: \(error)")
        }
    }
}
