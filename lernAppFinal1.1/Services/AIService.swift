import Foundation
import Combine
import OpenAISwift

// DTO für Flashcards, wie sie aus der KI-JSON erwartet werden
private struct FlashcardDTO: Codable {
    let front: String
    let back: String
}

protocol AIServiceProtocol {
    func summarizeText(text: String) -> AnyPublisher<(short: String, long: String), Error>
    func generateQuestions(text: String) -> AnyPublisher<[String], Error>
    func generateFlashcards(from text: String) -> AnyPublisher<[(front: String, back: String)], Error>
}

class AIService: AIServiceProtocol {
    private let client: OpenAISwift?
    private let isAvailable: Bool

    init(apiKey: String? = nil) {
        // Versuche Schlüssel aus Parameter, Config.plist (Config.value) oder Info.plist zu lesen
        let key = apiKey
            ?? Config.value(for: "OPENAI_API_KEY")
            ?? Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String

        if let key = key, !key.isEmpty {
            let config = OpenAISwift.Config.makeDefaultOpenAI(apiKey: key)
            self.client = OpenAISwift(config: config)
            self.isAvailable = true
        } else {
            self.client = nil
            self.isAvailable = false
            print("⚠️ AIService: OPENAI_API_KEY nicht gefunden. AI-Funktionen sind deaktiviert.")
        }
    }

    func summarizeText(text: String) -> AnyPublisher<(short: String, long: String), Error> {
        guard isAvailable else {
            return Fail(error: NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "AI key missing"])).eraseToAnyPublisher()
        }

        let shortPrompt = "Summarize this text in 2-3 sentences:\n\(text)"
        let longPrompt = "Summarize this text in detail (one paragraph):\n\(text)"

        let shortPublisher = requestChat(prompt: shortPrompt)
        let longPublisher = requestChat(prompt: longPrompt)

        return Publishers.Zip(shortPublisher, longPublisher)
            .map { (short: $0, long: $1) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    func generateQuestions(text: String) -> AnyPublisher<[String], Error> {
        guard isAvailable else {
            return Fail(error: NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "AI key missing"])).eraseToAnyPublisher()
        }

        let prompt = "Generate 3 study questions from the following text:\n\(text)"
        return requestChat(prompt: prompt)
            .map { output in
                output
                    .components(separatedBy: "\n")
                    .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    .filter { !$0.isEmpty }
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // Neue Funktion: Forder die KI auf, Flashcards als JSON zurückzugeben
    func generateFlashcards(from text: String) -> AnyPublisher<[(front: String, back: String)], Error> {
        guard isAvailable else {
            return Fail(error: NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "AI key missing"])).eraseToAnyPublisher()
        }

        let prompt =
        """
        From the following text produce up to 8 concise flashcards (front/back).
        Respond **only** with valid JSON array like:
        [{"front":"Question or prompt","back":"Answer or explanation"}, ...]
        Do not include any other commentary. Text:\n\(text)
        """

        return requestChat(prompt: prompt)
            .tryMap { responseString in
                // Versuche JSON-Parsing: isolieren des ersten '[' ... ']' Bereiches
                guard let start = responseString.firstIndex(of: "["),
                      let end = responseString.lastIndex(of: "]"),
                      start < end else {
                    throw NSError(domain: "AIService", code: 2, userInfo: [NSLocalizedDescriptionKey: "AI response did not contain JSON array"])
                }
                let jsonSubstring = responseString[start...end]
                let jsonData = Data(jsonSubstring.utf8)
                let decoder = JSONDecoder()
                let dtos = try decoder.decode([FlashcardDTO].self, from: jsonData)
                return dtos.map { ($0.front, $0.back) }
            }
            .catch { error -> AnyPublisher<[(front:String, back:String)], Error> in
                // Fallback: wenn JSON nicht geparst werden kann, versuche simple line-based parsing
                return Just(self.responseStringToPairs(response: error))
                    .setFailureType(to: Error.self)
                    .eraseToAnyPublisher()
            }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    // MARK: - Helper: requestChat
    private func requestChat(prompt: String) -> AnyPublisher<String, Error> {
        return Future<String, Error> { [weak self] promise in
            guard let client = self?.client else {
                promise(.failure(NSError(domain: "AIService", code: 1, userInfo: [NSLocalizedDescriptionKey: "AI key missing"])))
                return
            }
            client.sendChat(with: [.init(role: .user, content: prompt)]) { result in
                switch result {
                case .success(let response):
                    let text = response.choices?.first?.message.content ?? ""
                    promise(.success(text))
                case .failure(let error):
                    promise(.failure(error))
                }
            }
        }.eraseToAnyPublisher()
    }

    // Fallback-Parser (falls KI nicht saubere JSON liefert)
    private func responseStringToPairs(response: Error) -> [(front: String, back: String)] {
        // Dieser Fallback wird im `catch` benutzt — implementiere etwas konservatives
        // (Hier geben wir leere Liste zurück, bessere Fallbacks kannst du implementieren.)
        print("AI parsing fallback used: \(response.localizedDescription)")
        return []
    }
}
