//
//  AIPredictionView.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import SwiftUI

struct AIPredictionView: View {
    @Binding var predictionText: String
    @State private var isEditing: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("AI Prediction:")
                    .font(.subheadline)
                    .bold()
                Spacer()
                Button(action: { isEditing.toggle() }) {
                    Text(isEditing ? "Done" : "Edit")
                }
                .accessibilityLabel(isEditing ? "Done editing prediction" : "Edit prediction")
            }
            if isEditing {
                TextField("Prediction", text: $predictionText)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .accessibilityLabel("Edit AI prediction")
            } else {
                Text(predictionText.isEmpty ? "No prediction" : predictionText)
                    .font(.body)
                    .accessibilityLabel("AI prediction result")
            }
        }
        .padding(.vertical, 8)
    }
}
