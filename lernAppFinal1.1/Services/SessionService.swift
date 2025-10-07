
import Foundation
import Combine
import FirebaseFirestore
import FirebaseFirestoreSwift

protocol SessionServiceProtocol {
    func createSession(session: Session) -> AnyPublisher<Session, Error>
    func fetchSessions(userId: String) -> AnyPublisher<[Session], Error>
    func updateSession(session: Session) -> AnyPublisher<Session, Error>
}

class SessionService: SessionServiceProtocol {
    private let db = FirebaseManager.shared.firestore()
    private let collection = "sessions"

    func createSession(session: Session) -> AnyPublisher<Session, Error> {
        return Future<Session, Error> { promise in
            do {
                _ = try self.db.collection(self.collection).addDocument(from: session) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        // Firestore automatically generates an ID, we need to fetch it back
                        // This is a simplified approach, in a real app you might use a listener or return the document ID
                        promise(.success(session)) // Assuming session ID is set after creation or not critical for immediate return
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    func fetchSessions(userId: String) -> AnyPublisher<[Session], Error> {
        return Future<[Session], Error> { promise in
            self.db.collection(self.collection).whereField("userId", isEqualTo: userId).getDocuments { (querySnapshot, error) in
                if let error = error {
                    promise(.failure(error))
                } else {
                    do {
                        let sessions = try querySnapshot?.documents.compactMap { document in
                            try document.data(as: Session.self)
                        } ?? []
                        promise(.success(sessions))
                    } catch {
                        promise(.failure(error))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }

    func updateSession(session: Session) -> AnyPublisher<Session, Error> {
        guard let sessionId = session.id else {
            return Fail(error: SessionServiceError.invalidSessionId).eraseToAnyPublisher()
        }
        return Future<Session, Error> { promise in
            do {
                try self.db.collection(self.collection).document(sessionId).setData(from: session) { error in
                    if let error = error {
                        promise(.failure(error))
                    } else {
                        promise(.success(session))
                    }
                }
            } catch {
                promise(.failure(error))
            }
        }.eraseToAnyPublisher()
    }

    enum SessionServiceError: Error {
        case invalidSessionId
    }
}


