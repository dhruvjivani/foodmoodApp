import SwiftUI
internal import CoreData

struct DetailView: View {
    @ObservedObject var entry: LogEntry
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode

    @State private var showingDeleteConfirm = false
    @State private var showingShare = false
    @State private var exportURL: URL? = nil
    @State private var showExportErrorAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {

                // MARK: Meal Name
                Text(entry.mealName ?? "Meal")
                    .font(.title)
                    .bold()
                    .accessibilityLabel("Meal name: \(entry.mealName ?? "unknown")")

                // MARK: Date
                Text((entry.date ?? Date()), style: .date)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // MARK: Photo
                if let data = entry.photo,
                   let uiImage = UIImage(data: data) {

                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .accessibilityLabel("Meal photo")
                        .accessibilityAddTraits(.isImage)

                } else {
                    Image(systemName: "photo")
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity)
                        .foregroundColor(.gray)
                        .accessibilityLabel("No meal photo available")
                }

                // MARK: Mood
                HStack {
                    Text("Mood:")
                        .font(.headline)
                    Text(entry.mood ?? "Unknown")
                        .font(.body)
                }

                // MARK: Calories
                HStack {
                    Text("Calories:")
                        .font(.headline)
                    Text("\(entry.calories)")
                        .font(.body)
                }

                // MARK: AI Prediction
                if let pred = entry.aiPrediction,
                   !pred.isEmpty {
                    HStack {
                        Text("AI Prediction:")
                            .font(.headline)
                        Text(pred)
                            .font(.body)
                    }
                }

                // MARK: Notes
                if let notes = entry.notes,
                   !notes.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes")
                            .font(.headline)
                        Text(notes)
                            .font(.body)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                }

                Spacer()
            }
            .padding()
        }
        .navigationTitle("Entry Details")
        .toolbar {

            // MARK: Export Button
            ToolbarItem(placement: .primaryAction) {
                Button("Export") {
                    do {
                        let url = try FileExportManager.export(entry: entry)
                        exportURL = url
                        showingShare = true
                    } catch {
                        showExportErrorAlert = true
                    }
                }
                .accessibilityLabel("Export entry")
            }

            // MARK: Delete Button
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(role: .destructive) {
                    showingDeleteConfirm = true
                } label: {
                    Text("Delete")
                }
                .accessibilityLabel("Delete entry")
            }
        }

        // MARK: Share Sheet
        .sheet(isPresented: $showingShare) {
            if let url = exportURL {
                ShareSheet(activityItems: [url])
            } else {
                Text("Nothing to share.")
            }
        }

        // MARK: Export Error Alert
        .alert("Export Failed", isPresented: $showExportErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("Unable to export this entry.")
        }

        // MARK: Delete Confirmation
        .confirmationDialog(
            "Are you sure you want to delete this entry?",
            isPresented: $showingDeleteConfirm,
            titleVisibility: .visible
        ) {
            Button("Delete", role: .destructive) {
                deleteEntry()
            }
            Button("Cancel", role: .cancel) {}
        }
    }

    // MARK: Delete Logic
    private func deleteEntry() {
        viewContext.delete(entry)
        do {
            try viewContext.save()
            presentationMode.wrappedValue.dismiss()
        } catch {
            print("Error deleting entry: \(error)")
        }
    }
}
