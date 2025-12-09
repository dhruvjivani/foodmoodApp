//
//  CoreMLManager.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//

import Foundation
import CoreML
import Vision
import UIKit

/// A standalone manager for all AI-related tasks.
final class CoreMLManager {

    static let shared = CoreMLManager()

    private var model: VNCoreMLModel?

    private init() {
        loadModel()
    }

    /// Loads the CoreML model using VNCoreMLModel for Vision requests.
    private func loadModel() {
        do {
            let config = MLModelConfiguration()
            let classifier = try FoodClassifier(configuration: config)
            model = try VNCoreMLModel(for: classifier.model)
        } catch {
            print("❌ Failed to load CoreML model: \(error)")
        }
    }

    /// Predicts food type from a UIImage using Vision.
    func predictFood(from image: UIImage) async throws -> String {
        guard let model = model else {
            throw NSError(domain: "CoreML", code: -1, userInfo: [NSLocalizedDescriptionKey: "Model not loaded"])
        }

        guard let ciImage = CIImage(image: image) else {
            throw NSError(domain: "CoreML", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid CIImage"])
        }

        return try await withCheckedThrowingContinuation { continuation in
            let handler = VNImageRequestHandler(ciImage: ciImage, options: [:])

            let request = VNCoreMLRequest(model: model) { request, error in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }

                guard let results = request.results as? [VNClassificationObservation],
                      let top = results.first else {
                    continuation.resume(throwing: NSError(
                        domain: "CoreML",
                        code: -3,
                        userInfo: [NSLocalizedDescriptionKey: "No prediction results"]
                    ))
                    return
                }

                continuation.resume(returning: top.identifier)
            }

            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: error)
            }
        }
    }
}
