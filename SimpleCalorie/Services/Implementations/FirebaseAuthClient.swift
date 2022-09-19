//
//  FirebaseClient.swift
//  SimpleCalorie
//
//  Created by MK on 14/09/2022.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseFirestoreSwift

class FirebaseAuthClient: AuthClient {
    
    private var userKey = "current_user"
    
    var currentUser: User? {
        get {
            if let data = UserDefaults.standard.data(forKey: userKey) {
                return try? JSONDecoder().decode(User.self, from: data)
            } else {
                return nil
            }
        }
        
        set {
            if let data = try? JSONEncoder().encode(newValue) {
                UserDefaults.standard.set(data, forKey: userKey)
            } else {
                UserDefaults.standard.removeObject(forKey: userKey)
            }
        }
    }
        
    private let db = Firestore.firestore()
    
    // MARK: - AuthClient
    
    func signIn(email: String, password: String) async -> User? {
        guard
            let userId = try? await Auth.auth().signIn(withEmail: email, password: password).user.uid
        else {
            return nil
        }

        if let dbUser = try? await db.collection(Path.users).document(userId).getDocument(as: User.self) {
            self.currentUser = dbUser
            return dbUser
        }
        
        let user = User(id: userId, isAdmin: false, kCalLimit: Const.kCalDefaultLimit) // Default values for a new user
        
        do {
            try db.collection(Path.users).document(userId).setData(from: user)
        } catch {
            return nil
        }
        
        self.currentUser = user
        
        return user
    }
    
    func signOut() {
        currentUser = nil
    }
    
}



private struct Path {
    
    static let users = "users"
    
}
