
import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isAuthenticated = false
    @Published var errorMessage: String? = nil

    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService
    }

    func register() {
        authService.register(email: email, password: password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isAuthenticated = false
                }
            }, receiveValue: { user in
                self.isAuthenticated = true
                self.errorMessage = nil
                print("User registered: \(user.email)")
            })
            .store(in: &cancellables)
    }

    func login() {
        authService.login(email: email, password: password)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                    self.isAuthenticated = false
                }
            }, receiveValue: { user in
                self.isAuthenticated = true
                self.errorMessage = nil
                print("User logged in: \(user.email)")
            })
            .store(in: &cancellables)
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
                self.isAuthenticated = false
                self.errorMessage = nil
                print("User logged out")
            })
            .store(in: &cancellables)
    }
}


