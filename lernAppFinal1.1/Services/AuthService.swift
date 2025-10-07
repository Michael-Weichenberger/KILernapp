
import Foundation
import Combine
import FirebaseAuth
import FirebaseFirestore

protocol AuthServiceProtocol {
    func register(email: String, password: String) -> AnyPublisher<User, Error>
    func login(email: String, password: String) -> AnyPublisher<User, Error>
    func logout() -> AnyPublisher<Void, Error>
    var currentUser: User? { get }
}

class AuthService: AuthServiceProtocol {
    @Published var firebaseUser: FirebaseAuth.User? // Firebase user object
    private var authStateDidChangeListenerHandle: AuthStateDidChangeListenerHandle?

    init() {
        authStateDidChangeListenerHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
            self?.firebaseUser = user
        }
    }

    deinit {
        if let handle = authStateDidChangeListenerHandle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }

    var currentUser: User? {
        if let firebaseUser = firebaseUser {
            return User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
        }
        return nil
    }

    func register(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let firebaseUser = authResult?.user else {
                    promise(.failure(AuthError.unknownError))
                    return
                }
                let newUser = User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
                // Save user to Firestore
                FirebaseManager.shared.firestore().collection("users").document(newUser.id).setData([
                    "email": newUser.email,
                    "id": newUser.id
                ]) { err in
                    if let err = err {
                        promise(.failure(err))
                        return
                    }
                    promise(.success(newUser))
                }
            }
        }.eraseToAnyPublisher()
    }

    func login(email: String, password: String) -> AnyPublisher<User, Error> {
        return Future<User, Error> { promise in
            Auth.auth().signIn(withEmail: email, password: password) { authResult, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                guard let firebaseUser = authResult?.user else {
                    promise(.failure(AuthError.unknownError))
                    return
                }
                let loggedInUser = User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
                promise(.success(loggedInUser))
            }
        }.eraseToAnyPublisher()
    }

    func logout() -> AnyPublisher<Void, Error> {
        return Future<Void, Error> { promise in
            do {
                try Auth.auth().signOut()
                promise(.success(()))
            } catch let signOutError as NSError {
                promise(.failure(signOutError))
            }
        }.eraseToAnyPublisher()
    }

    enum AuthError: Error {
        case invalidCredentials
        case unknownError
    }
}


