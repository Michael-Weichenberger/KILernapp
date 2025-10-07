
import Foundation
import Combine

class SummaryViewModel: ObservableObject {
    @Published var shortSummary: String = ""
    @Published var longSummary: String = ""
    @Published var generatedQuestions: [String] = []
    @Published var errorMessage: String? = nil

    private let aiService: AIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(aiService: AIServiceProtocol = AIService()) {
        self.aiService = aiService
    }

    func generateSummariesAndQuestions(text: String) {
        aiService.summarizeText(text: text)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { (short, long) in
                self.shortSummary = short
                self.longSummary = long
            })
            .store(in: &cancellables)

        aiService.generateQuestions(text: text)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { questions in
                self.generatedQuestions = questions
            })
            .store(in: &cancellables)
    }
}


