import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

protocol AuthServiceProtocol {
    var currentUser: User? { get }
    var isAuthenticatedPublisher: AnyPublisher<Bool, Never> { get }
    var currentUserPublisher: AnyPublisher<User?, Never> { get }

    func register(email: String, password: String, userName: String?) -> AnyPublisher<User, Error>
    func login(email: String, password: String) -> AnyPublisher<User, Error>
    func logout() -> AnyPublisher<Void, Error>
}

class AuthService: AuthServiceProtocol {
    @Published private var firebaseUser: FirebaseAuth.User? = nil
    private var authStateHandle: AuthStateDidChangeListenerHandle?
    private let firestore = Firestore.firestore()

    init() {
        authStateHandle = Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.firebaseUser = user
        }
    }

    deinit {
        if let handle = authStateHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    var isAuthenticatedPublisher: AnyPublisher<Bool, Never> {
        $firebaseUser.map { $0 != nil }.eraseToAnyPublisher()
    }

    var currentUserPublisher: AnyPublisher<User?, Never> {
        $firebaseUser
            .flatMap { firebaseUser -> AnyPublisher<User?, Never> in
                guard let firebaseUser = firebaseUser else { return Just(nil).eraseToAnyPublisher() }

                return Future<User?, Never> { promise in
                    self.firestore.collection("users").document(firebaseUser.uid)
                        .getDocument { snapshot, _ in
                            if let data = snapshot?.data() {
                                let user = User(
                                    id: firebaseUser.uid,
                                    email: firebaseUser.email ?? "",
                                    userName: data["userName"] as? String,
                                    apiKey: data["apiKey"] as? String
                                )
                                promise(.success(user))
                            } else {
                                let user = User(id: firebaseUser.uid, email: firebaseUser.email ?? "", userName: nil, apiKey: nil)
                                promise(.success(user))
                            }
                        }
                }
                .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }

    var currentUser: User? {
        firebaseUser.flatMap { User(id: $0.uid, email: $0.email ?? "", userName: nil, apiKey: nil) }
    }

    func register(email: String, password: String, userName: String? = nil) -> AnyPublisher<User, Error> {
        Future<User, Error> { [weak self] promise in
            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let firebaseUser = result?.user else {
                    promise(.failure(AuthError.unknown))
                    return
                }

                var userData: [String: Any] = ["id": firebaseUser.uid, "email": firebaseUser.email ?? ""]
                if let userName = userName {
                    userData["userName"] = userName
                }

                self?.firestore.collection("users").document(firebaseUser.uid)
                    .setData(userData, merge: true) { err in
                        if let err = err {
                            promise(.failure(err))
                        } else {
                            let user = User(id: firebaseUser.uid, email: firebaseUser.email ?? "", userName: userName, apiKey: nil)
                            promise(.success(user))
                        }
                    }
            }
        }.eraseToAnyPublisher()
    }

    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        Future<User, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { result, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let firebaseUser = result?.user else {
                    promise(.failure(AuthError.unknown))
                    return
                }

                let user = User(id: firebaseUser.uid, email: firebaseUser.email ?? "", userName: nil, apiKey: nil)
                promise(.success(user))
            }
        }.eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, Error> {
        Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    enum AuthError: Error { case unknown }
}
