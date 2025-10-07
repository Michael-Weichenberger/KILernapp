import Foundation
import Combine
import FirebaseFirestore

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
        guard let currentUser = authService.currentUser else { return }
        userEmail = currentUser.email

        // Firestore User-Daten laden
        let userDoc = Firestore.firestore().collection("users").document(currentUser.id)
        userDoc.getDocument { snapshot, error in
            if let data = snapshot?.data() {
                self.userName = data["userName"] as? String ?? currentUser.email.components(separatedBy: "@").first ?? "User"
            } else {
                self.userName = currentUser.email.components(separatedBy: "@").first ?? "User"
            }
        }

        // API Key aus Info.plist holen
        if let key = Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String {
            self.openAIApiKey = key
        } else {
            self.openAIApiKey = ""
            print("⚠️ OPENAI_API_KEY nicht gefunden!")
        }
    }

    func saveSettings() {
        guard let currentUser = authService.currentUser else { return }
        let data: [String: Any] = [
            "userName": userName
        ]
        Firestore.firestore().collection("users").document(currentUser.id)
            .setData(data, merge: true) { error in
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    print("Settings saved for user \(currentUser.id)")
                }
            }
    }

    func logout() {
        authService.logout()
            .sink(receiveCompletion: { completion in
                if case .failure(let error) = completion {
                    self.errorMessage = error.localizedDescription
                }
            }, receiveValue: { _ in
                print("User logged out from settings.")
            })
            .store(in: &cancellables)
    }
}
