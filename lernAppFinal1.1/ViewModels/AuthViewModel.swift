import Foundation
import Combine

class AuthViewModel: ObservableObject {
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var userName: String = ""

    @Published var currentUser: User? = nil
    @Published var isAuthenticated: Bool = false
    @Published var errorMessage: String? = nil

    private let authService: AuthServiceProtocol
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthServiceProtocol = AuthService()) {
        self.authService = authService

        authService.isAuthenticatedPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$isAuthenticated)

        authService.currentUserPublisher
            .receive(on: DispatchQueue.main)
            .assign(to: &$currentUser)
    }

    func register() {
        authService.register(email: email, password: password, userName: userName)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.currentUser = user
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }

    func login() {
        authService.login(email: email, password: password)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] user in
                self?.currentUser = user
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }

    func logout() {
        authService.logout()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] in
                self?.currentUser = nil
                self?.errorMessage = nil
            }
            .store(in: &cancellables)
    }
}
