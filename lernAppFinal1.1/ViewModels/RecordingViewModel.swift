import Foundation
import Combine

// MARK: - Recording ViewModel
class RecordingViewModel: ObservableObject {
    @Published var isRecording: Bool = false
    @Published var transcription: String = ""
    
    let cardsViewModel: CardsViewModel
    private let audioService: AudioServiceProtocol
    var cancellables = Set<AnyCancellable>()
    
    init(audioService: AudioServiceProtocol = AudioService(), cardsViewModel: CardsViewModel) {
        self.audioService = audioService
        self.cardsViewModel = cardsViewModel
        
        audioService.transcriptionPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] text in
                guard let self = self else { return }
                self.transcription += "\n" + text
                self.cardsViewModel.generateCardsFromText(text)
            }
            .store(in: &cancellables)
    }
    
    func startRecording() {
        audioService.startRecording()
        isRecording = true
    }
    
    func stopRecording() {
        audioService.stopRecording()
        isRecording = false
    }
}
