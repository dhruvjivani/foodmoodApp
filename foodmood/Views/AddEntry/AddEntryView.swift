// AddEntryView.swift
// FoodMood
//
// Created by Dhruv Rasikbhai Jivani on 12/4/25.

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
            Form {
                // MARK: Meal section
                Section(header: Text("Meal").font(.headline)) {
                    TextField("Meal name", text: $viewModel.mealName)
                        .font(.body)
                        .accessibilityLabel("Meal Name")

                    Picker("Mood", selection: $viewModel.selectedMood) {
                        ForEach(Mood.allCases, id: \.self) { mood in
                            Text(mood.displayName).tag(mood)
                        }
                    }
                    .accessibilityLabel("Mood Picker")

                    Stepper("Calories: \(viewModel.calories)",
                            value: $viewModel.calories,
                            in: 0...20000)
                    .accessibilityLabel("Calories Stepper")

                    TextEditor(text: $viewModel.notes)
                        .frame(minHeight: 100)
                        .accessibilityLabel("Notes")
                }

                // MARK: Photo section
                Section(header: Text("Photo")) {
                    if let data = viewModel.photoData,
                       let preview = UIImage(data: data) {
                        Image(uiImage: preview)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 200)
                            .cornerRadius(8)
                            .accessibilityLabel("Selected meal photo")
                            .accessibilityAddTraits(.isImage)
                    } else {
                        Text("No photo selected")
                            .font(.body)
                    }

                    HStack {
                        Button("Pick Photo") {
                            showingImagePicker = true
                        }
                        .accessibilityLabel("Pick Photo")

                        Spacer()

                        Button("Take Photo") {
                            showingImagePicker = true
                        }
                        .accessibilityLabel("Take Photo")
                    }
                }

                // MARK: AI section
                Section(header: Text("AI")) {
                    if uiImage != nil {
                        if aiVM.isLoading {
                            ProgressView()
                                .accessibilityLabel("AI is analyzing the image")
                        } else {
                            AIPredictionView(predictionText: $viewModel.aiPrediction)
                        }
                    } else {
                        Text("Add a photo to get an AI prediction.")
                            .font(.body)
                    }
                }
            }
            .navigationTitle("Add Entry")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if viewModel.validateBeforeSave() {
                            do {
                                try viewModel.save(in: viewContext)
                                presentationMode.wrappedValue.dismiss()
                            } catch {
                                showSaveErrorAlert = true
                            }
                        }
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
                    // img is already non-optional UIImage here
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
            .alert("Save Failed", isPresented: $showSaveErrorAlert, actions: {
                Button("OK", role: .cancel) {}
            }, message: {
                Text("Unable to save entry. Please try again.")
            })
        }
    }
}
