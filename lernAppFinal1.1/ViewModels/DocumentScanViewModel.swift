import Foundation
import UIKit
import Combine
import Vision

class DocumentScanViewModel: ObservableObject {
    @Published var pages: [PageResult] = []   // Alle gescannten Seiten
    @Published var errorMessage: String? = nil

    private let ocrService: OCRServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(ocrService: OCRServiceProtocol = OCRService()) {
        self.ocrService = ocrService
    }

    func processImage(_ image: UIImage) {
        guard let data = image.pngData() else {
            errorMessage = "Bild konnte nicht verarbeitet werden"
            return
        }

        ocrService.performOCR(imageData: data)
            .sink(receiveCompletion: { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] text in
                let page = PageResult(image: image, text: text)
                self?.pages.append(page)
            })
            .store(in: &cancellables)
    }

    func clear() {
        pages.removeAll()
        errorMessage = nil
    }

    /// Alle Texte zusammenfügen → für SummaryView
    func combinedText() -> String {
        pages.map { $0.text }.joined(separator: "\n\n")
    }
}
