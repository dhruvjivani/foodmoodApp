//
//  Mood.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import SwiftUI
import Combine

enum Mood: String, CaseIterable, Identifiable {
    case happy
    case sad
    case neutral
    case excited
    case tired

    var id: String { self.rawValue }

    // Emoji representation
    var emoji: String {
        switch self {
        case .happy: return "😊"
        case .sad: return "😢"
        case .neutral: return "😐"
        case .excited: return "🤩"
        case .tired: return "😴"
        }
    }

    // Human-readable text for UI (used heavily in Pickers)
    var displayName: String {
        switch self {
        case .happy:
            return "😊 Happy"
        case .sad:
            return "😢 Sad"
        case .neutral:
            return "😐 Neutral"
        case .excited:
            return "🤩 Excited"
        case .tired:
            return "😴 Tired"
        }
    }
}
