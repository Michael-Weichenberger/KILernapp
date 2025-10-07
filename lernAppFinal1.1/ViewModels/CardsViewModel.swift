import Foundation
import Combine

class CardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentCard: Card? = nil
    @Published var showBack: Bool = false
    @Published var errorMessage: String? = nil
    @Published var newCardFront: String = ""
    @Published var newCardBack: String = ""
    @Published var completedCards: [Card] = []
    @Published var generatedCardsForPreview: [Card] = []

    private let cardService: CardServiceProtocol
    private let authService: AuthServiceProtocol
    private let aiService: AIServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    var upcomingCount: Int {
        cards.filter { $0.nextReviewDate <= Date() }.count
    }

    init(cardService: CardServiceProtocol = CardService(),
         authService: AuthServiceProtocol = AuthService(),
         aiService: AIServiceProtocol = AIService()) {
        self.cardService = cardService
        self.authService = authService
        self.aiService = aiService
    }

    // MARK: - Karten laden
    func loadCards() {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "User not logged in."
            return
        }
        cardService.getCards(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { cards in
                self.cards = cards.sorted { $0.nextReviewDate < $1.nextReviewDate }
                self.setupNextCard()
            })
            .store(in: &cancellables)
    }

    // MARK: - Karte hinzufügen (keine Duplikate)
    func addCard() {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "User not logged in."
            return
        }
        guard !newCardFront.isEmpty && !newCardBack.isEmpty else {
            errorMessage = "Vorder- und Rückseite dürfen nicht leer sein."
            return
        }
        
        // Prüfen ob Karte schon existiert
        if cards.contains(where: { $0.front == newCardFront && $0.back == newCardBack }) {
            errorMessage = "Diese Karte existiert bereits."
            return
        }

        cardService.addCard(front: newCardFront, back: newCardBack, userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { card in
                self.cards.append(card)
                self.cards.sort { $0.nextReviewDate < $1.nextReviewDate }
                if self.currentCard == nil { self.currentCard = card }
                self.newCardFront = ""
                self.newCardBack = ""
            })
            .store(in: &cancellables)
    }

    // MARK: - KI-Karten
    func generateCardsFromTextForPreview(_ text: String) {
        guard let userId = authService.currentUser?.id else { return }

        aiService.generateFlashcards(from: text)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = "AI error: \(error.localizedDescription)"
                }
            }, receiveValue: { flashcards in
                self.generatedCardsForPreview = flashcards.map {
                    Card(id: UUID().uuidString, userId: userId, front: $0.front, back: $0.back, easeFactor: 2.5, repetitions: 0, nextReviewDate: Date(), lastReviewDate: Date())
                }
            })
            .store(in: &cancellables)
    }

    func generateCardsFromText(_ text: String) {
        generateCardsFromTextForPreview(text)
    }

    func saveGeneratedCards() {
        guard let userId = authService.currentUser?.id else { return }

        for card in generatedCardsForPreview {
            // Duplikate vermeiden
            if !cards.contains(where: { $0.front == card.front && $0.back == card.back }) {
                cardService.addCard(front: card.front, back: card.back, userId: userId)
                    .receive(on: DispatchQueue.main)
                    .sink(receiveCompletion: { _ in }, receiveValue: { savedCard in
                        self.cards.append(savedCard)
                        self.cards.sort { $0.nextReviewDate < $1.nextReviewDate }
                    })
                    .store(in: &cancellables)
            }
        }

        generatedCardsForPreview.removeAll()
    }

    // MARK: - Review / Karte bewerten
    func recordReview(difficulty: Int) {
        guard let card = currentCard else { return }
        cardService.recordReview(card: card, difficulty: difficulty)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { updatedCard in
                if let index = self.cards.firstIndex(where: { $0.id == updatedCard.id }) {
                    self.cards[index] = updatedCard
                }

                self.completedCards.append(updatedCard)
                self.setupNextCard()
                self.showBack = false
            })
            .store(in: &cancellables)
    }

    private func setupNextCard() {
        let now = Date()
        if let next = cards.first(where: { $0.nextReviewDate <= now && !completedCards.contains($0) }) {
            currentCard = next
        } else {
            currentCard = nil
        }
    }

    func replayCompletedCards() {
        // Karten ohne Duplikate mergen
        for card in completedCards {
            if !cards.contains(where: { $0.id == card.id }) {
                cards.append(card)
            }
        }

        // Shuffle für Zufall
        cards.shuffle()
        completedCards.removeAll()

        // Nächste Karte setzen
        setupNextCard()
    }

    func flipCard() {
        showBack.toggle()
    }
}

