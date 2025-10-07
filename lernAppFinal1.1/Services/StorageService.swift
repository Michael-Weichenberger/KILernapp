
import Foundation
import Combine
import FirebaseStorage

protocol StorageServiceProtocol {
    func uploadAudio(data: Data, userId: String, sessionId: String) -> AnyPublisher<URL, Error>
    func uploadDocument(data: Data, userId: String, sessionId: String) -> AnyPublisher<URL, Error>
}

class StorageService: StorageServiceProtocol {
    private let storage = FirebaseManager.shared.storage

    func uploadAudio(data: Data, userId: String, sessionId: String) -> AnyPublisher<URL, Error> {
        return Future<URL, Error> { promise in
            let storageRef = self.storage.reference().child("audio/").child(userId).child("\(sessionId).m4a")
            storageRef.putData(data, metadata: nil) { metadata, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let downloadURL = url else {
                        promise(.failure(StorageServiceError.downloadURLMissing))
                        return
                    }
                    promise(.success(downloadURL))
                }
            }
        }.eraseToAnyPublisher()
    }

    func uploadDocument(data: Data, userId: String, sessionId: String) -> AnyPublisher<URL, Error> {
        return Future<URL, Error> { promise in
            let storageRef = self.storage.reference().child("documents/").child(userId).child("\(sessionId).pdf")
            storageRef.putData(data, metadata: nil) { metadata, error in
                if let error = error {
                    promise(.failure(error))
                    return
                }
                storageRef.downloadURL { url, error in
                    if let error = error {
                        promise(.failure(error))
                        return
                    }
                    guard let downloadURL = url else {
                        promise(.failure(StorageServiceError.downloadURLMissing))
                        return
                    }
                    promise(.success(downloadURL))
                }
            }
        }.eraseToAnyPublisher()
    }

    enum StorageServiceError: Error {
        case downloadURLMissing
    }
}

