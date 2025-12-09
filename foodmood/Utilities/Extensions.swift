//
//  Extensions.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import SwiftUI
import UIKit

// MARK: - Optional Unwrapping Extensions
extension Optional where Wrapped == String {
    var orEmpty: String { self ?? "" }
}

extension Optional where Wrapped == UIImage {
    var orPlaceholder: UIImage {
        self ?? UIImage(systemName: "photo") ?? UIImage()
    }
}

// MARK: - View Extensions
extension View {
    /// Embed in AnyView
    var any: AnyView { AnyView(self) }

    /// Rounded background card for better UI consistency
    func cardBackground() -> some View {
        self
            .padding()
            .background(Color(.secondarySystemBackground))
            .cornerRadius(12)
    }
}
