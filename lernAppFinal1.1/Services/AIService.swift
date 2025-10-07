
import Foundation
import Combine

protocol AIServiceProtocol {
    func summarizeText(text: String) -> AnyPublisher<(short: String, long: String), Error>
    func generateQuestions(text: String) -> AnyPublisher<[String], Error>
}

class AIService: AIServiceProtocol {
    func summarizeText(text: String) -> AnyPublisher<(short: String, long: String), Error> {
        return Future<(short: String, long: String), Error> { promise in
            print("Summarizing text...")
            // Placeholder for AI summarization API call
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                let shortSummary = "This is a short AI-generated summary of the provided text."
                let longSummary = "This is a longer, more detailed AI-generated summary of the provided text, covering various aspects and key points."
                promise(.success((short: shortSummary, long: longSummary)))
            }
        }.eraseToAnyPublisher()
    }

    func generateQuestions(text: String) -> AnyPublisher<[String], Error> {
        return Future<[String], Error> { promise in
            print("Generating questions...")
            // Placeholder for AI question generation API call
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                let questions = [
                    "What is the main topic of the text?",
                    "Can you explain the key concept discussed?",
                    "What are the implications of the information presented?"
                ]
                promise(.success(questions))
            }
        }.eraseToAnyPublisher()
    }
}


