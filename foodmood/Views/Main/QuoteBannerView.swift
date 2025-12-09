//
//  QuoteBannerView.swift
//  foodmood
//
//  Created by Dhruv Rasikbhai Jivani on 12/8/25.
//

import SwiftUI

struct QuoteBannerView: View {
    @StateObject private var quoteVM = QuoteViewModel()

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {

            Text("Daily Motivation")
                .font(.headline)

            if quoteVM.isLoading {
                ProgressView()
                    .accessibilityLabel("Loading quote")
            } else {
                Text("“\(quoteVM.quoteText)”")
                    .font(.body)
                    .accessibilityLabel("Quote: \(quoteVM.quoteText)")
                
                if !quoteVM.author.isEmpty {
                    Text("- \(quoteVM.author)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .padding()
        .background(Color(.secondarySystemBackground))
        .cornerRadius(10)
        .onAppear {
            quoteVM.fetchQuote()
        }
    }
}
