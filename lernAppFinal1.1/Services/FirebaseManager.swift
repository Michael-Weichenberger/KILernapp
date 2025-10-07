import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

final class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() {
        // FirebaseApp.configure() muss in AppDelegate oder @main App Struct aufgerufen werden
    }
    
    // MARK: - Auth
    var auth: Auth {
        return Auth.auth()
    }
    
    var currentUser: User? {
        guard let firebaseUser = auth.currentUser else { return nil }
        
        // Firestore auslesen für username + apiKey
        let doc = firestore.collection("users").document(firebaseUser.uid)
        var user = User(
            id: firebaseUser.uid,
            email: firebaseUser.email ?? "",
            userName: "",
            apiKey: ""
        )
        
        doc.getDocument { snapshot, error in
            guard let data = snapshot?.data(), error == nil else { return }
            user.userName = data["userName"] as? String ?? ""
            user.apiKey = data["apiKey"] as? String ?? ""
        }
        
        return user
    }
    
    func signUp(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let firebaseUser = result?.user else {
                completion(.failure(FirebaseManagerError.unknown))
                return
            }
            
            // Neues User-Objekt mit Defaults
            let newUser = User(
                id: firebaseUser.uid,
                email: firebaseUser.email ?? "",
                userName: "",
                apiKey: ""
            )
            
            // Firestore initial befüllen
            self.firestore.collection("users").document(newUser.id).setData([
                "email": newUser.email,
                "userName": newUser.userName,
                "apiKey": newUser.apiKey
            ]) { error in
                if let error = error {
                    completion(.failure(error))
                } else {
                    completion(.success(newUser))
                }
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
        auth.signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            guard let firebaseUser = result?.user else {
                completion(.failure(FirebaseManagerError.unknown))
                return
            }
            
            // User aus Firestore laden
            let doc = self.firestore.collection("users").document(firebaseUser.uid)
            doc.getDocument { snapshot, error in
                if let data = snapshot?.data(), error == nil {
                    let user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        userName: data["userName"] as? String ?? "",
                        apiKey: data["apiKey"] as? String ?? ""
                    )
                    completion(.success(user))
                } else {
                    // Fallback
                    let user = User(
                        id: firebaseUser.uid,
                        email: firebaseUser.email ?? "",
                        userName: "",
                        apiKey: ""
                    )
                    completion(.success(user))
                }
            }
        }
    }
    
    func signOut() throws {
        try auth.signOut()
    }
    
    // MARK: - Firestore
    var firestore: Firestore {
        return Firestore.firestore()
    }
    
    func collection(_ name: String) -> CollectionReference {
        return firestore.collection(name)
    }
    
    // MARK: - Storage
    var storage: Storage {
        return Storage.storage()
    }
    
    func storageReference(path: String) -> StorageReference {
        return storage.reference(withPath: path)
    }
    
    // MARK: - Custom Errors
    enum FirebaseManagerError: Error {
        case unknown
    }
}
