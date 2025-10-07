import SwiftUI
import Combine

struct RecordingView: View {
    @StateObject private var cardsVM = CardsViewModel()
    @StateObject private var viewModel: RecordingViewModel

    @State private var recordingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    @State private var showPreviewSheet = false

    init() {
        let cardsVM = CardsViewModel()
        _cardsVM = StateObject(wrappedValue: cardsVM)
        _viewModel = StateObject(wrappedValue: RecordingViewModel(cardsViewModel: cardsVM))
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Hintergrund
                LinearGradient(
                    gradient: Gradient(colors: [Color.black, Color.blue.opacity(0.4), Color.purple.opacity(0.4)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()

                // Glow-Kreise
                Circle()
                    .fill(Color.purple.opacity(0.25))
                    .frame(width: 280, height: 280)
                    .blur(radius: 80)
                    .offset(x: -150, y: -200)

                Circle()
                    .fill(Color.blue.opacity(0.2))
                    .frame(width: 300, height: 300)
                    .blur(radius: 100)
                    .offset(x: 150, y: 250)

                VStack(spacing: 20) {
                    // Header
                    HStack {
                        Image(systemName: "mic.circle.fill")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.white.opacity(0.9))

                        Text("Audio Recorder")
                            .font(.largeTitle.bold())
                            .foregroundColor(.white)

                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)

                    // Timer Anzeige
                    Text("Laufzeit: \(formatTime(recordingTime))")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(.vertical, 10)

                    // Aufnahme-Status
                    Rectangle()
                        .fill(.ultraThinMaterial)
                        .frame(height: 100)
                        .cornerRadius(20)
                        .overlay(
                            Text(viewModel.isRecording ? "Recording..." : "Idle")
                                .foregroundColor(.white)
                                .font(.headline)
                        )
                        .padding(.horizontal)

                    // Start/Stop Button
                    Button(action: { viewModel.isRecording ? stopRecording() : startRecording() }) {
                        Image(systemName: viewModel.isRecording ? "stop.circle.fill" : "record.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(viewModel.isRecording ? .red : .green)
                            .shadow(radius: 10)
                    }
                    .padding(.top, 20)

                    // Transkription anzeigen
                    if !viewModel.transcription.isEmpty {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Transcription:")
                                .font(.headline)
                                .foregroundColor(.white)

                            ScrollView {
                                Text(viewModel.transcription)
                                    .padding()
                                    .background(.ultraThinMaterial)
                                    .cornerRadius(15)
                                    .foregroundColor(.white)
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding(.horizontal)
                    }

                    Spacer()
                }

                // Toast für Fehler
                if let message = cardsVM.errorMessage {
                    ToastView(message: message, isShowing: Binding(
                        get: { cardsVM.errorMessage != nil },
                        set: { _ in cardsVM.errorMessage = nil }
                    ))
                    .padding(.top, 50)
                    .animation(.easeInOut, value: cardsVM.errorMessage)
                }
            }
            .navigationTitle("Record Audio")
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear { stopRecording() }
            .sheet(isPresented: $showPreviewSheet) {
                // KI-Vorschau Sheet
                VStack {
                    Text("KI-Vorschau: Karten überprüfen")
                        .font(.headline)
                        .padding()

                    ScrollView {
                        ForEach($cardsVM.generatedCardsForPreview) { $card in
                            VStack(spacing: 8) {
                                TextField("Vorderseite", text: $card.front)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                TextField("Rückseite", text: $card.back)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                            }
                            .padding()
                        }
                    }

                    HStack(spacing: 16) {
                        Button("Speichern") {
                            cardsVM.saveGeneratedCards()
                            showPreviewSheet = false
                        }
                        .buttonStyle(PrimaryButtonStyle(color: .blue))

                        Button("Abbrechen") {
                            cardsVM.generatedCardsForPreview.removeAll()
                            showPreviewSheet = false
                        }
                        .buttonStyle(PrimaryButtonStyle(color: .red))
                    }
                    .padding()
                }
            }
        }
    }

    // MARK: - Recording Logic
    private func startRecording() {
        viewModel.startRecording()
        recordingTime = 0
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            recordingTime += 1
        }

        // Sheet öffnen, sobald neue KI-Karten generiert werden
        cardsVM.$generatedCardsForPreview
            .dropFirst()
            .sink { cards in
                if !cards.isEmpty {
                    withAnimation { showPreviewSheet = true }
                }
            }
            .store(in: &viewModel.cancellables)
    }

    private func stopRecording() {
        viewModel.stopRecording()
        timer?.invalidate()
        timer = nil
    }

    private func formatTime(_ interval: TimeInterval) -> String {
        String(format: "%02d:%02d", Int(interval)/60, Int(interval)%60)
    }
}

// MARK: - Preview
struct RecordingView_Previews: PreviewProvider {
    static var previews: some View {
        RecordingView()
    }
}
