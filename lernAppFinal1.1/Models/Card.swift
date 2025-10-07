import Foundation

struct Card: Identifiable, Codable, Equatable {
    var id: String
    var userId: String
    var front: String
    var back: String
    var easeFactor: Double
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewDate: Date

    static func == (lhs: Card, rhs: Card) -> Bool {
        lhs.id == rhs.id
    }
}
