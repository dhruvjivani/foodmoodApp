//
//  AIRecognitionViewModel.swift
//  FoodMood
//
//  Created by Dhruv Rasikbhai Jivani on 12/4/25.
//
import Foundation
import CoreML
import UIKit
import Vision
import Combine

final class AIRecognitionViewModel: ObservableObject {
    @Published var prediction: String = ""
    @Published var isLoading: Bool = false
    @Published var errorMessage: String? = nil

    private var model: VNCoreMLModel?

    init() {
        do {
            // Replace FoodClassifier with the real model class name if different
            let config = MLModelConfiguration()
            let mlModel = try FoodClassifier(configuration: config).model
            self.model = try VNCoreMLModel(for: mlModel)
        } catch {
            print("CoreML model load error:", error)
            errorMessage = "Model unavailable"
        }
    }

    func classify(image: UIImage) {
        guard let cgImage = image.cgImage, let model = model else {
            errorMessage = "Unable to prepare image or model."
            return
        }
        isLoading = true
        let request = VNCoreMLRequest(model: model) { [weak self] req, err in
            DispatchQueue.main.async {
                self?.isLoading = false
                if let results = req.results as? [VNClassificationObservation], let top = results.first {
                    self?.prediction = top.identifier
                } else {
                    self?.errorMessage = "No confident prediction"
                }
            }
        }
        request.imageCropAndScaleOption = .centerCrop
        let handler = VNImageRequestHandler(cgImage: cgImage)
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.isLoading = false
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
}
