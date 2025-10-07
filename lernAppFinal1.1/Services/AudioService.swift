import Foundation
import Combine
import AVFoundation

protocol AudioServiceProtocol {
    func startRecording()
    func stopRecording()
    var transcriptionPublisher: AnyPublisher<String, Never> { get }
}

class AudioService: AudioServiceProtocol {
    private var recorder: AVAudioRecorder?
    private var audioURL: URL?
    
    private var transcriptionSubject = PassthroughSubject<String, Never>()
    var transcriptionPublisher: AnyPublisher<String, Never> {
        transcriptionSubject.eraseToAnyPublisher()
    }
    
    private var chunkIndex = 0
    private let maxChunkDuration: TimeInterval = 90 * 60 // 90 Minuten
    
    func startRecording() {
        stopCurrentRecording() // vorherige Aufnahme sicher beenden
        
        let session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playAndRecord, mode: .default, options: [.defaultToSpeaker])
            try session.setActive(true)
            
            let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            chunkIndex += 1
            audioURL = docs.appendingPathComponent("aufnahme_chunk_\(chunkIndex).m4a")
            
            let settings: [String: Any] = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
            ]
            
            recorder = try AVAudioRecorder(url: audioURL!, settings: settings)
            recorder?.record(forDuration: maxChunkDuration) // maximale Länge
            print("Started chunk \(chunkIndex)")
        } catch {
            print("Fehler beim Starten der Aufnahme: \(error)")
        }
    }
    
    func stopRecording() {
        stopCurrentRecording()
    }
    
    private func stopCurrentRecording() {
        guard let recorder = recorder else { return }
        recorder.stop()
        if let url = audioURL {
            transcribeChunk(url)
        }
        self.recorder = nil
    }
    
    private func getApiKey() -> String? {
        guard let path = Bundle.main.path(forResource: "Config", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let key = dict["OPENAI_API_KEY"] as? String else { return nil }
        return key
    }
    
    private func transcribeChunk(_ audioURL: URL) {
        guard let apiKey = getApiKey() else { return }
        
        let endpoint = URL(string: "https://api.openai.com/v1/audio/transcriptions")!
        var request = URLRequest(url: endpoint)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        let audioData: Data
        do { audioData = try Data(contentsOf: audioURL) } catch { return }
        
        var body = Data()
        let boundaryPrefix = "--\(boundary)\r\n"
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"chunk.m4a\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: audio/m4a\r\n\r\n".data(using: .utf8)!)
        body.append(audioData)
        body.append("\r\n".data(using: .utf8)!)
        body.append(boundaryPrefix.data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"model\"\r\n\r\n".data(using: .utf8)!)
        body.append("whisper-1\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body
        
        URLSession.shared.dataTask(with: request) { data, _, _ in
            guard let data = data,
                  let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                  let text = json["text"] as? String else { return }
            
            DispatchQueue.main.async {
                self.transcriptionSubject.send(text)
                try? FileManager.default.removeItem(at: audioURL)
            }
        }.resume()
    }
}
