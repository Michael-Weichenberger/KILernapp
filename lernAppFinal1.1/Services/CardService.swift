import Foundation
import Combine
import FirebaseFirestore

protocol CardServiceProtocol {
    func addCard(front: String, back: String, userId: String) -> AnyPublisher<Card, Error>
    func getCards(userId: String) -> AnyPublisher<[Card], Error>
    func recordReview(card: Card, difficulty: Int) -> AnyPublisher<Card, Error>
}

class CardService: CardServiceProtocol {
    private let db = Firestore.firestore()
    private let collection = "cards"

    func addCard(front: String, back: String, userId: String) -> AnyPublisher<Card, Error> {
        let newCard = Card(
            id: UUID().uuidString,
            userId: userId,
            front: front,
            back: back,
            easeFactor: 2.5,
            repetitions: 0,
            nextReviewDate: Date(),
            lastReviewDate: Date()
        )
        return saveCard(newCard)
    }

    func getCards(userId: String) -> AnyPublisher<[Card], Error> {
        Future<[Card], Error> { [weak self] promise in
            guard let self = self else { return }
            self.db.collection(self.collection)
                .whereField("userId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    let cards = snapshot?.documents.compactMap { try? $0.data(as: Card.self) } ?? []
                    promise(.success(cards))
                }
        }.eraseToAnyPublisher()
    }

    func recordReview(card: Card, difficulty: Int) -> AnyPublisher<Card, Error> {
        var updated = card
        let q = Double(difficulty)
        
        if q >= 3 {
            updated.repetitions += 1
            let interval: Int
            switch updated.repetitions {
            case 1: interval = 1
            case 2: interval = 6
            default: interval = Int(round(Double(updated.repetitions) * updated.easeFactor))
            }
            updated.nextReviewDate = Calendar.current.date(byAdding: .day, value: interval, to: Date())!
            updated.easeFactor = max(1.3, updated.easeFactor + (0.1 - (5.0 - q) * (0.08 + (5.0 - q) * 0.02)))
        } else {
            updated.repetitions = 0
            updated.nextReviewDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        }
        updated.lastReviewDate = Date()
        return saveCard(updated)
    }

    private func saveCard(_ card: Card) -> AnyPublisher<Card, Error> {
        Future<Card, Error> { [weak self] promise in
            guard let self = self else { return }
            do {
                try self.db.collection(self.collection)
                    .document(card.id)
                    .setData(from: card, merge: true) { error in
                        if let error = error {
                            promise(.failure(error))
                        } else {
                            promise(.success(card))
                        }
                    }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }
}
