
import Foundation
import Combine

class CardsViewModel: ObservableObject {
    @Published var cards: [Card] = []
    @Published var currentCard: Card? = nil
    @Published var showBack: Bool = false
    @Published var errorMessage: String? = nil

    private let cardService: CardServiceProtocol
    private let authService: AuthServiceProtocol // To get current user ID
    private var cancellables = Set<AnyCancellable>()

    init(cardService: CardServiceProtocol = CardService(), authService: AuthServiceProtocol = AuthService()) {
        self.cardService = cardService
        self.authService = authService
    }

    func loadCards() {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "User not logged in."
            return
        }
        cardService.getCards(userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { cards in
                self.cards = cards.sorted { $0.nextReviewDate < $1.nextReviewDate }
                self.currentCard = self.cards.first
            })
            .store(in: &cancellables)
    }

    func addCard(front: String, back: String) {
        guard let userId = authService.currentUser?.id else {
            errorMessage = "User not logged in."
            return
        }
        cardService.addCard(front: front, back: back, userId: userId)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { card in
                self.cards.append(card)
                self.cards.sort { $0.nextReviewDate < $1.nextReviewDate }
                if self.currentCard == nil { self.currentCard = card }
            })
            .store(in: &cancellables)
    }

    func recordReview(difficulty: Int) {
        guard var card = currentCard else { return }
        cardService.recordReview(card: card, difficulty: difficulty)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { updatedCard in
                if let index = self.cards.firstIndex(where: { $0.id == updatedCard.id }) {
                    self.cards[index] = updatedCard
                }
                self.cards.sort { $0.nextReviewDate < $1.nextReviewDate }
                self.currentCard = self.cards.first(where: { $0.id != updatedCard.id && $0.nextReviewDate <= Date() }) ?? self.cards.first
                self.showBack = false
            })
            .store(in: &cancellables)
    }

    func flipCard() {
        showBack.toggle()
    }

    func nextCard() {
        guard let current = currentCard else { return }
        if let currentIndex = cards.firstIndex(where: { $0.id == current.id }) {
            let nextIndex = (currentIndex + 1) % cards.count
            currentCard = cards[nextIndex]
            showBack = false
        }
    }
}


