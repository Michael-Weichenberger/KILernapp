
import Foundation

struct User: Identifiable, Codable {
    let id: String
    let email: String
    var userName: String?
    var apiKey: String?
}
