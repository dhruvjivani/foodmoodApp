//
//  Quote.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import Foundation

struct Quote: Codable {
    let text: String
    let author: String?
}

struct QuoteResponse: Codable {
    let content: String
    let author: String
    
    func toQuote() -> Quote {
        Quote(text: content, author: author)
    }
}
