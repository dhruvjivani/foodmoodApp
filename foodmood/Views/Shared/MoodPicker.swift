//
//  MoodPicker.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import SwiftUI

struct MoodPicker: View {

    @Binding var selectedMood: Mood

    var body: some View {
        Picker("Mood", selection: $selectedMood) {
            ForEach(Mood.allCases) { mood in
                Text(mood.rawValue).tag(mood)
            }
        }
    }
}
