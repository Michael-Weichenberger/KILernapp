
import Foundation
import Combine

class SettingsViewModel: ObservableObject {
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var openAIApiKey: String = ""
    @Published var errorMessage: String? = nil

    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
        loadUserSettings()
    }

    func loadUserSettings() {
        if let currentUser = authService.currentUser {
            userName = currentUser.email.components(separatedBy: "@").first ?? "User"
            userEmail = currentUser.email
        }
        // Load API Key from Keychain (placeholder)
        openAIApiKey = "sk-xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
    }

    func saveOpenAIApiKey() {
        // Save API Key to Keychain (placeholder)
        print("Saving OpenAI API Key: \(openAIApiKey)")
    }

    func logout() {
        authService.logout()
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { _ in
                print("User logged out from settings.")
            })
            .store(in: &cancellables)
    }
}


