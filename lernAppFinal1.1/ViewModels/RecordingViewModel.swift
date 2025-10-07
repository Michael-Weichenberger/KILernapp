
import Foundation
import Combine

class RecordingViewModel: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var recordingTime: TimeInterval = 0.0
    @Published var transcription: String = ""
    @Published var errorMessage: String? = nil

    private let audioService: AudioServiceProtocol
    private var cancellables = Set<AnyCancellable>()
    private var timer: Timer? // For simulating recording time

    init(audioService: AudioServiceProtocol = AudioService()) {
        self.audioService = audioService
    }

    func startRecording() {
        audioService.startRecording()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isRecording = true
                    self.startTimer()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { _ in })
            .store(in: &cancellables)
    }

    func stopRecording() {
        audioService.stopRecording()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    self.isRecording = false
                    self.stopTimer()
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { audioData in
                self.transcribeAudio(audioData: audioData)
            })
            .store(in: &cancellables)
    }

    private func transcribeAudio(audioData: Data) {
        audioService.transcribeAudio(audioData: audioData)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { transcription in
                self.transcription = transcription
            })
            .store(in: &cancellables)
    }

    private func startTimer() {
        recordingTime = 0.0
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.recordingTime += 1.0
        }
    }

    private func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}


