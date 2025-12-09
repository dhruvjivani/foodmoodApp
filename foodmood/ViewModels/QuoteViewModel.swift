//
//  QuoteViewModel.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import Foundation
import Combine

final class QuoteViewModel: ObservableObject {
    @Published var quoteText: String = "Keep going — you are doing great!"
    @Published var author: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil
    
    private var cancellables = Set<AnyCancellable>()
    private let urlString = "https://zenquotes.io/api/today"

    func fetchQuote(retries: Int = 1) {
        guard let url = URL(string: urlString) else { return }
        isLoading = true
        errorMessage = nil
        URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, response -> Data in
                guard let http = response as? HTTPURLResponse, 200..<300 ~= http.statusCode else {
                    throw URLError(.badServerResponse)
                }
                return data
            }
            .decode(type: [Quote].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                switch completion {
                    case .failure(_):
                        if retries > 0 {
                            self?.fetchQuote(retries: retries - 1)
                        } else {
                            self?.errorMessage = "Could not fetch quote. Showing default."
                            self?.quoteText = "Keep going — you are doing great!"
                            self?.author = ""
                        }
                    case .finished: break
                }
            }, receiveValue: { [weak self] quotes in
                if let first = quotes.first {
                    self?.quoteText = first.text
                    self?.author = first.author ?? "Unknown"
                }
            })
            .store(in: &cancellables)
    }
}
