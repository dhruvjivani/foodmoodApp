// AddEntryView.swift
// FoodMood
//
// Updated for enhanced UI design.

import SwiftUI
internal import CoreData

struct AddEntryView: View {
    @StateObject private var viewModel = AddEntryViewModel()
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var aiVM = AIRecognitionViewModel()
    @State private var showingImagePicker = false
    @State private var uiImage: UIImage? = nil
    @State private var showSaveErrorAlert = false

    var body: some View {
        NavigationView {
            ZStack {
                // Soft gradient background
                LinearGradient(
                    colors: [Color.teal.opacity(0.22), Color.blue.opacity(0.18)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                Form {
                    // MARK: - Summary header
                    Section {
                        HStack(alignment: .center, spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color.purple, Color.blue],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 60, height: 60)

                                Text(viewModel.selectedMood.emoji)
                                    .font(.largeTitle)
                            }

                            VStack(alignment: .leading, spacing: 6) {
                                Text("New FoodMood Entry")
                                    .font(.headline)
                                Text("Log what you ate and how you feel.")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                HStack(spacing: 12) {
                                    Label("\(viewModel.calories) kcal", systemImage: "flame.fill")
                                        .font(.caption)
                                        .foregroundColor(.orange)
                                    Label(viewModel.selectedMood.displayName, systemImage: "face.smiling")
                                        .font(.caption)
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                        .padding(.vertical, 4)
                    }

                    // MARK: - Meal section
                    Section(header: Text("Meal Details").font(.headline)) {
                        HStack {
                            Image(systemName: "fork.knife")
                                .foregroundColor(.accentColor)
                            TextField("Meal name", text: $viewModel.mealName)
                                .font(.body)
                                .accessibilityLabel("Meal Name")
                        }

                        HStack {
                            Image(systemName: "face.smiling")
                                .foregroundColor(.accentColor)
                            Picker("Mood", selection: $viewModel.selectedMood) {
                                ForEach(Mood.allCases, id: \.self) { mood in
                                    Text(mood.displayName).tag(mood)
                                }
                            }
                            .accessibilityLabel("Mood Picker")
                        }

                        HStack {
                            Image(systemName: "flame.fill")
                                .foregroundColor(.orange)
                            Stepper(
                                "Calories: \(viewModel.calories)",
                                value: $viewModel.calories,
                                in: 0...20000
                            )
                            .accessibilityLabel("Calories Stepper")
                        }

                        VStack(alignment: .leading) {
                            HStack {
                                Image(systemName: "note.text")
                                    .foregroundColor(.accentColor)
                                Text("Notes")
                                    .font(.subheadline)
                            }

                            TextEditor(text: $viewModel.notes)
                                .frame(minHeight: 90)
                                .accessibilityLabel("Notes")
                        }
                    }

                    // MARK: - Photo section
                    Section(header: Text("Meal Photo").font(.headline)) {
                        if let data = viewModel.photoData,
                           let preview = UIImage(data: data) {
                            Image(uiImage: preview)
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 220)
                                .cornerRadius(12)
                                .shadow(radius: 4)
                                .accessibilityLabel("Selected meal photo")
                                .accessibilityAddTraits(.isImage)
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "photo.on.rectangle")
                                    .foregroundColor(.secondary)
                                Text("No photo selected")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }

                        HStack {
                            Button {
                                showingImagePicker = true
                            } label: {
                                Label("Pick Photo", systemImage: "photo")
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.accentColor)
                            .accessibilityLabel("Pick Photo")

                            Spacer()

                            Button {
                                showingImagePicker = true
                            } label: {
                                Label("Take Photo", systemImage: "camera")
                            }
                            .buttonStyle(.bordered)
                            .accessibilityLabel("Take Photo")
                        }
                    }

                    // MARK: - AI section
                    Section(header: Text("AI Food Recognition").font(.headline)) {
                        if uiImage != nil {
                            if aiVM.isLoading {
                                HStack(spacing: 8) {
                                    ProgressView()
                                    Text("Analyzing your meal…")
                                        .font(.subheadline)
                                }
                                .accessibilityLabel("AI is analyzing the image")
                            } else {
                                AIPredictionView(predictionText: $viewModel.aiPrediction)
                            }
                        } else {
                            HStack(spacing: 8) {
                                Image(systemName: "sparkles")
                                    .foregroundColor(.purple)
                                Text("Add a photo and let AI guess your meal.")
                                    .font(.body)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Add Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button {
                        if viewModel.validateBeforeSave() {
                            do {
                                try viewModel.save(in: viewContext)
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                showSaveErrorAlert = true
                            }
                        }
                    } label: {
                        Text("Save")
                            .fontWeight(.semibold)
                    }
                    .disabled(viewModel.saveDisabled)
                    .accessibilityLabel("Save Entry")
                }

                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                    .accessibilityLabel("Cancel")
                }
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePickerView(image: $uiImage, onImagePicked: { img in
                    if let data = img.jpegData(compressionQuality: 0.8) {
                        viewModel.photoData = data
                    }
                    uiImage = img
                    aiVM.classify(image: img)
                })
            }
            .alert(isPresented: $viewModel.showValidationAlert) {
                Alert(
                    title: Text("Validation"),
                    message: Text(viewModel.validationMessage),
                    dismissButton: .default(Text("OK"))
                )
            }
            .alert("Save Failed", isPresented: $showSaveErrorAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                Text("Unable to save entry. Please try again.")
            }
        }
    }
}
