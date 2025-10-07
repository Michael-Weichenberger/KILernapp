
import Foundation
import Combine

protocol CardServiceProtocol {
    func addCard(front: String, back: String, userId: String) -> AnyPublisher<Card, Error>
    func getCards(userId: String) -> AnyPublisher<[Card], Error>
    func updateCard(card: Card) -> AnyPublisher<Card, Error>
    func recordReview(card: Card, difficulty: Int) -> AnyPublisher<Card, Error>
}

class CardService: CardServiceProtocol {
    private var cards: [Card] = [] // In-memory storage for demonstration

    func addCard(front: String, back: String, userId: String) -> AnyPublisher<Card, Error> {
        return Future<Card, Error> { promise in
            let newCard = Card(
                id: UUID().uuidString,
                userId: userId,
                front: front,
                back: back,
                easeFactor: 2.5, // Initial ease factor for SM-2
                repetitions: 0,
                nextReviewDate: Date(),
                lastReviewDate: Date()
            )
            self.cards.append(newCard)
            promise(.success(newCard))
        }.eraseToAnyPublisher()
    }

    func getCards(userId: String) -> AnyPublisher<[Card], Error> {
        return Future<[Card], Error> { promise in
            let userCards = self.cards.filter { $0.userId == userId }
            promise(.success(userCards))
        }.eraseToAnyPublisher()
    }

    func updateCard(card: Card) -> AnyPublisher<Card, Error> {
        return Future<Card, Error> { promise in
            if let index = self.cards.firstIndex(where: { $0.id == card.id }) {
                self.cards[index] = card
                promise(.success(card))
            } else {
                promise(.failure(CardServiceError.cardNotFound))
            }
        }.eraseToAnyPublisher()
    }

    func recordReview(card: Card, difficulty: Int) -> AnyPublisher<Card, Error> {
        return Future<Card, Error> { promise in
            var updatedCard = card
            // SM-2 Algorithm implementation
            // q: quality of the response (0-5)
            let q = Double(difficulty)

            if q >= 3 {
                // Correct response
                if updatedCard.repetitions == 0 {
                    updatedCard.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())! // 1 day
                } else if updatedCard.repetitions == 1 {
                    updatedCard.nextReviewDate = Calendar.current.date(byAdding: .day, value: 6, to: Date())! // 6 days
                } else {
                    let interval = Int(round(Double(updatedCard.repetitions) * updatedCard.easeFactor))
                    updatedCard.nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())!
                }
                updatedCard.repetitions += 1
                updatedCard.easeFactor = updatedCard.easeFactor + (0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02))
                if updatedCard.easeFactor < 1.3 { updatedCard.easeFactor = 1.3 }
            } else {
                // Incorrect response
                updatedCard.repetitions = 0
                updatedCard.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
            }
            updatedCard.lastReviewDate = Date()

            if let index = self.cards.firstIndex(where: { $0.id == updatedCard.id }) {
                self.cards[index] = updatedCard
                promise(.success(updatedCard))
            } else {
                promise(.failure(CardServiceError.cardNotFound))
            }
        }.eraseToAnyPublisher()
    }

    enum CardServiceError: Error {
        case cardNotFound
        case unknownError
    }
}


