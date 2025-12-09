//
//  QuoteService.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import Foundation

class QuoteService {
    func fetchQuote() async throws -> Quote {
        guard let url = URL(string: "https://api.quotable.io/random") else {
            throw URLError(.badURL)
        }

        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(QuoteResponse.self, from: data)
        return response.toQuote()
    }
}
