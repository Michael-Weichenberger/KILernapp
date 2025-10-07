import Foundation
import Combine
import FirebaseFirestore

class HomeViewModel: ObservableObject {
    @Published var welcomeMessage: String = "Willkommen zurück!"
    @Published var upcomingCards: [Card] = []
    @Published var recentSessions: [Session] = []
    @Published var errorMessage: String? = nil
    
    private let cardService: CardServiceProtocol
    private let sessionService: SessionServiceProtocol
    private let authService: AuthServiceProtocol
    private let settingsViewModel: SettingsViewModel
    private var cancellables = Set<AnyCancellable>()
    
    init(
        cardService: CardServiceProtocol = CardService(),
        sessionService: SessionServiceProtocol = SessionService(),
        authService: AuthServiceProtocol = AuthService(),
        settingsViewModel: SettingsViewModel = SettingsViewModel()
    ) {
        self.cardService = cardService
        self.sessionService = sessionService
        self.authService = authService
        self.settingsViewModel = settingsViewModel
        
        bindUserName()
        loadAllData()
    }
    
    private func bindUserName() {
        settingsViewModel.$userName
            .receive(on: DispatchQueue.main)
            .sink { [weak self] name in
                guard let self = self else { return }
                if let emailPart = self.authService.currentUser?.email.components(separatedBy: "@").first {
                    self.welcomeMessage = name.isEmpty ? "Willkommen zurück, \(emailPart)!" : "Willkommen zurück, \(name)!"
                }
            }
            .store(in: &cancellables)
    }
    
    private func loadAllData() {
        loadWelcomeMessage()
        loadUpcomingCards()
        loadRecentSessions()
    }
    
    func loadWelcomeMessage() {
        guard let currentUser = authService.currentUser else {
            welcomeMessage = "Willkommen zurück, Gast!"
            return
        }
        
        let userDoc = Firestore.firestore().collection("users").document(currentUser.id)
        userDoc.getDocument { [weak self] snapshot, error in
            DispatchQueue.main.async {
                guard let self = self else { return }
                if let data = snapshot?.data(), let name = data["userName"] as? String {
                    self.welcomeMessage = "Willkommen zurück, \(name)!"
                } else {
                    let emailPart = currentUser.email.components(separatedBy: "@").first ?? "Gast"
                    self.welcomeMessage = "Willkommen zurück, \(emailPart)!"
                }
            }
        }
    }
    
    func loadUpcomingCards() {
        guard let userId = authService.currentUser?.id else { return }
        
        cardService.getCards(userId: userId)
            .map { $0.filter { $0.nextReviewDate <= Date() } }
            .map { $0.sorted { $0.nextReviewDate < $1.nextReviewDate } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Cards Error: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] cards in
                self?.upcomingCards = cards
            }
            .store(in: &cancellables)
    }
    
    func loadRecentSessions() {
        guard let userId = authService.currentUser?.id else { return }
        
        sessionService.fetchSessions(userId: userId)
            .map { $0.sorted { $0.timestamp > $1.timestamp } }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = "Sessions Error: \(error.localizedDescription)"
                }
            } receiveValue: { [weak self] sessions in
                self?.recentSessions = sessions
            }
            .store(in: &cancellables)
    }
}
