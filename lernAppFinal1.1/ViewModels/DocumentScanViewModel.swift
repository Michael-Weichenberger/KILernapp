
import Foundation
import Combine

class DocumentScanViewModel: ObservableObject {
    @Published var scannedText: String = ""
    @Published var errorMessage: String? = nil

    private let ocrService: OCRServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(ocrService: OCRServiceProtocol = OCRService()) {
        self.ocrService = ocrService
    }

    func processScannedImage(imageData: Data) {
        ocrService.performOCR(imageData: imageData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { text in
                self.scannedText = text
            })
            .store(in: &cancellables)
    }
}


