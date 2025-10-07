import SwiftUI
import Combine

struct CardsView: View {
    @StateObject private var viewModel: CardsViewModel
    @StateObject private var recordingVM: RecordingViewModel
    @State private var transcriptionCancellable: AnyCancellable?
    @State private var showAllCardsSheet = false

    init(viewModel: CardsViewModel, recordingVM: RecordingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
        _recordingVM = StateObject(wrappedValue: recordingVM)
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
                    headerView
                    progressAndCardView
                    Spacer()
                    addCardView
                    Divider().padding(.vertical, 8)
                    recordingView
                    showAllCardsButton
                }
                .padding(.top, 20)

                toastView
            }
            .navigationTitle("Flashcards")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.loadCards()
                transcriptionCancellable = recordingVM.$transcription
                    .dropFirst()
                    .debounce(for: .seconds(1), scheduler: RunLoop.main)
                    .sink { text in
                        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                        viewModel.generateCardsFromText(text)
                    }
            }
            .onDisappear {
                transcriptionCancellable?.cancel()
            }
            .sheet(isPresented: $showAllCardsSheet) {
                allCardsSheet
            }
        }
    }

    // MARK: - Subviews

    private var headerView: some View {
        HStack {
            Image(systemName: "square.stack.3d.up.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white.opacity(0.9))

            Text("Flashcards")
                .font(.largeTitle.bold())
                .foregroundColor(.white)

            Spacer()
        }
        .padding(.horizontal)
        .padding(.top, 20)
    }

    private var progressAndCardView: some View {
        VStack(spacing: 12) {
            // Progress Bar
            if !viewModel.cards.isEmpty {
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 12)

                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.green.opacity(0.85))
                        .frame(
                            width: UIScreen.main.bounds.width *
                                   CGFloat(viewModel.completedCards.count) /
                                   CGFloat(max(viewModel.cards.count, 1)),
                            height: 12
                        )
                        .animation(.easeInOut(duration: 0.3), value: viewModel.completedCards.count)
                }
                .frame(height: 12)
                .padding(.horizontal)
            }

            // Aktuelle Karte
            if let card = viewModel.currentCard {
                VStack(spacing: 12) {
                    Text(viewModel.showBack ? card.back : card.front)
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding(30)
                        .frame(maxWidth: .infinity, minHeight: 200)
                        .background(.ultraThinMaterial)
                        .cornerRadius(18)
                        .shadow(radius: 10)
                        .onTapGesture { viewModel.flipCard() }

                    if viewModel.showBack {
                        HStack(spacing: 12) {
                            Button("Schwer") { viewModel.recordReview(difficulty: 3) }
                                .buttonStyle(PrimaryButtonStyle(color: .red))

                            Button("Mittel") { viewModel.recordReview(difficulty: 2) }
                                .buttonStyle(PrimaryButtonStyle(color: .orange))

                            Button("Leicht") { viewModel.recordReview(difficulty: 1) }
                                .buttonStyle(PrimaryButtonStyle(color: .green))
                        }
                    }
                }
                .padding(.horizontal)
            } else {
                Text("Keine Karten verfügbar")
                    .foregroundColor(.gray)
                    .padding()
            }

            // Replay-Button für erledigte Karten
            if !viewModel.completedCards.isEmpty {
                Button("Erledigte Karten erneut üben") {
                    viewModel.replayCompletedCards()
                }
                .buttonStyle(PrimaryButtonStyle(color: .purple))
                .padding(.horizontal)
            }
        }
    }

    private var addCardView: some View {
        VStack(spacing: 10) {
            TextField("Vorderseite", text: $viewModel.newCardFront)
                .textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("Rückseite", text: $viewModel.newCardBack)
                .textFieldStyle(RoundedBorderTextFieldStyle())

            Button("Karte speichern") {
                viewModel.addCard()
            }
            .buttonStyle(PrimaryButtonStyle(color: .blue))
        }
        .padding(.horizontal)
    }

    private var recordingView: some View {
        VStack(spacing: 10) {
            Text("Automatisch erstellte Karten aus Audio")
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundColor(.white)
                .font(.headline)

            if !recordingVM.transcription.isEmpty {
                ScrollView {
                    Text(recordingVM.transcription)
                        .padding()
                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .foregroundColor(.white)
                }
                .frame(maxHeight: 180)
            } else {
                Text("Keine Transkription")
                    .foregroundColor(.gray)
            }

            HStack(spacing: 16) {
                Button(recordingVM.isRecording ? "Stop Recording" : "Start Recording") {
                    if recordingVM.isRecording {
                        recordingVM.stopRecording()
                    } else {
                        recordingVM.startRecording()
                    }
                }
                .buttonStyle(PrimaryButtonStyle(color: recordingVM.isRecording ? .red : .green))
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 20)
    }

    private var showAllCardsButton: some View {
        if !viewModel.cards.isEmpty {
            return AnyView(
                Button("Alle Karten anzeigen") {
                    showAllCardsSheet = true
                }
                .buttonStyle(PrimaryButtonStyle(color: .purple))
                .padding(.horizontal)
            )
        }
        return AnyView(EmptyView())
    }

    private var toastView: some View {
        Group {
            if let message = viewModel.errorMessage {
                ToastView(message: message, isShowing: Binding(
                    get: { viewModel.errorMessage != nil },
                    set: { _ in viewModel.errorMessage = nil }
                ))
                .padding(.top, 50)
                .animation(.easeInOut, value: viewModel.errorMessage)
            }
        }
    }

    private var allCardsSheet: some View {
        VStack(spacing: 16) {
            Text("Alle vorhandenen Karten")
                .font(.headline)
                .padding(.top)

            ScrollView {
                VStack(spacing: 12) {
                    let leicht = viewModel.cards.filter { $0.easeFactor <= 2.0 }
                    let mittel = viewModel.cards.filter { $0.easeFactor > 2.0 && $0.easeFactor < 3.0 }
                    let schwer = viewModel.cards.filter { $0.easeFactor >= 3.0 }

                    if !leicht.isEmpty {
                        Text("Leicht").bold().padding(.top, 8)
                        ForEach(leicht) { card in
                            MiniCardView(card: card, backgroundColor: Color.green.opacity(0.15)) {
                                viewModel.currentCard = card
                                showAllCardsSheet = false
                            }
                        }
                    }

                    if !mittel.isEmpty {
                        Text("Mittel").bold().padding(.top, 8)
                        ForEach(mittel) { card in
                            MiniCardView(card: card, backgroundColor: Color.orange.opacity(0.15)) {
                                viewModel.currentCard = card
                                showAllCardsSheet = false
                            }
                        }
                    }

                    if !schwer.isEmpty {
                        Text("Schwer").bold().padding(.top, 8)
                        ForEach(schwer) { card in
                            MiniCardView(card: card, backgroundColor: Color.red.opacity(0.15)) {
                                viewModel.currentCard = card
                                showAllCardsSheet = false
                            }
                        }
                    }
                }
                .padding(.horizontal)
            }

            Button("Schließen") {
                showAllCardsSheet = false
            }
            .buttonStyle(PrimaryButtonStyle(color: .blue))
            .padding(.bottom)
        }
    }
}

// MARK: - MiniCardView
struct MiniCardView: View {
    let card: Card
    let backgroundColor: Color
    let onTap: () -> Void
    @State private var isPressed = false

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(card.front)
                .font(.subheadline.bold())
                .foregroundColor(.white)
                .lineLimit(1)
            Text(card.back)
                .font(.footnote)
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(backgroundColor)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.3), radius: 4, x: 0, y: 2)
        .scaleEffect(isPressed ? 0.95 : 1.0)
        .animation(.spring(response: 0.25, dampingFraction: 0.6), value: isPressed)
        .contentShape(Rectangle())
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isPressed = true }
                .onEnded { _ in
                    isPressed = false
                    onTap()
                }
        )
    }
}
// MARK: - Preview
struct CardsView_Previews: PreviewProvider {
    static var previews: some View {
        let cards = [
            Card(id: "1", userId: "u1", front: "Was ist 2+2?", back: "4", easeFactor: 1.5, repetitions: 1, nextReviewDate: Date(), lastReviewDate: Date()),
            Card(id: "2", userId: "u1", front: "Was ist 3+3?", back: "6", easeFactor: 2.5, repetitions: 1, nextReviewDate: Date(), lastReviewDate: Date()),
            Card(id: "3", userId: "u1", front: "Was ist 5+5?", back: "10", easeFactor: 3.0, repetitions: 1, nextReviewDate: Date(), lastReviewDate: Date())
        ]
        let vm = CardsViewModel()
        vm.cards = cards
        vm.currentCard = cards.first
        let recordingVM = RecordingViewModel(cardsViewModel: vm)
        
        return CardsView(viewModel: vm, recordingVM: recordingVM)
    }
}
