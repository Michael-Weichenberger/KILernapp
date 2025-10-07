import Foundation
import Combine
import Vision

protocol OCRServiceProtocol {
    func performOCR(imageData: Data) -> AnyPublisher<String, Error>
}

class OCRService: OCRServiceProtocol {
    func performOCR(imageData: Data) -> AnyPublisher<String, Error> {
        return Future<String, Error> { promise in
            // Vision-Request
            let requestHandler = VNImageRequestHandler(data: imageData, options: [:])
            let request = VNRecognizeTextRequest { request, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                
                let recognizedText = request.results?
                    .compactMap { $0 as? VNRecognizedTextObservation }
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n") ?? ""
                
                promise(.success(recognizedText))
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["de", "en"]
            request.usesLanguageCorrection = true
            
            DispatchQueue.global(qos: .userInitiated).async {
                do {
                    try requestHandler.perform([request])
                } catch {
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }
}
