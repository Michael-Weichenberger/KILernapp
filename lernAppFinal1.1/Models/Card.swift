
import Foundation

struct Card: Identifiable, Codable {
    let id: String
    let userId: String
    let front: String
    let back: String
    var easeFactor: Double
    var repetitions: Int
    var nextReviewDate: Date
    var lastReviewDate: Date
}


