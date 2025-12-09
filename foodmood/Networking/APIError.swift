//
//  APIError.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import Foundation

enum APIError: LocalizedError {
    case invalidURL
    case requestFailed
    case decodingFailed
    case serverError(Int)
    case unknown

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid API URL."
        case .requestFailed:
            return "Network request failed. Please try again."
        case .decodingFailed:
            return "Unable to decode server response."
        case .serverError(let code):
            return "Server error: \(code)"
        case .unknown:
            return "Unknown error occurred."
        }
    }
}
