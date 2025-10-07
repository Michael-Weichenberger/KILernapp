import Foundation
import Combine
import FirebaseFirestore

protocol SessionServiceProtocol {
    func createSession(session: Session) -> AnyPublisher<Session, Error>
    func fetchSessions(userId: String) -> AnyPublisher<[Session], Error>
    func updateSession(session: Session) -> AnyPublisher<Session, Error>
}

class SessionService: SessionServiceProtocol {
    private let db = FirebaseManager.shared.firestore
    private let collection = "sessions"

    func createSession(session: Session) -> AnyPublisher<Session, Error> {
        let ref = db.collection(collection).document()
        var sessionWithId = session
        sessionWithId.id = ref.documentID
        return saveSession(sessionWithId)
    }

    func fetchSessions(userId: String) -> AnyPublisher<[Session], Error> {
        Future<[Session], Error> { [weak self] promise in
            guard let self = self else { return }
            self.db.collection(self.collection)
                .whereField("userId", isEqualTo: userId)
                .getDocuments { snapshot, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    do {
                        let sessions = try snapshot?.documents.compactMap { try $0.data(as: Session.self) } ?? []
                        promise(.success(sessions))
                    } catch {
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }

    func updateSession(session: Session) -> AnyPublisher<Session, Error> {
        guard let id = session.id else {
            return Fail(error: SessionServiceError.invalidSessionId).eraseToAnyPublisher()
        }
        return saveSession(session)
    }

    // MARK: - Helper: Save Session
    private func saveSession(_ session: Session) -> AnyPublisher<Session, Error> {
        Future<Session, Error> { [weak self] promise in
            guard let self = self else { return }
            do {
                try self.db.collection(self.collection)
                    .document(session.id!)
                    .setData(from: session, merge: true) { error in
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
