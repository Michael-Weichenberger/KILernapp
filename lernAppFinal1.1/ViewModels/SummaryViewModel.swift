import Foundation
import Combine

class SummaryViewModel: ObservableObject {
    @Published var shortSummary: String = ""
    @Published var longSummary: String = ""
    @Published var generatedQuestions: [String] = []
    @Published var errorMessage: String? = nil

    private let aiService: AIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(apiKey: String? = nil) {
        // Falls kein API-Key übergeben wird, aus Config.plist holen
        let key = apiKey ?? Config.value(for: "OPENAI_API_KEY") ?? ""
        self.aiService = AIService(apiKey: key)
    }

    func generateSummariesAndQuestions(text: String) {
        // Kurze & lange Zusammenfassung
        aiService.summarizeText(text: text)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] (short, long) in
                self?.shortSummary = short
                self?.longSummary = long
            })
            .store(in: &cancellables)

        // Generierte Fragen
        aiService.generateQuestions(text: text)
            .sink(receiveCompletion: { [weak self] completion in
                switch completion {
                case .finished: break
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] questions in
                self?.generatedQuestions = questions
            })
            .store(in: &cancellables)
    }
}

