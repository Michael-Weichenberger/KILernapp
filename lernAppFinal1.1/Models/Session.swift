
import Foundation
import FirebaseFirestoreSwift

struct Session: Identifiable, Codable {
    @DocumentID var id: String? = UUID().uuidString
    let userId: String
    let timestamp: Date
    var audioPath: String?
    var transcription: String?
    var documentScanPath: String?
    var ocrText: String?
    var summaryShort: String?
    var summaryLong: String?
    var generatedQuestions: [String]?

    // Initializer for creating new sessions
    init(userId: String, timestamp: Date, audioPath: String? = nil, transcription: String? = nil, documentScanPath: String? = nil, ocrText: String? = nil, summaryShort: String? = nil, summaryLong: String? = nil, generatedQuestions: [String]? = nil) {
        self.userId = userId
        self.timestamp = timestamp
        self.audioPath = audioPath
        self.transcription = transcription
        self.documentScanPath = documentScanPath
        self.ocrText = ocrText
        self.summaryShort = summaryShort
        self.summaryLong = summaryLong
        self.generatedQuestions = generatedQuestions
    }
}


