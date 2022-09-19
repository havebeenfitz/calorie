//
//  FirebaseUserClient.swift
//  SimpleCalorie
//
//  Created by MK on 16/09/2022.
//

import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirebaseUserClient: UserClient {
    
    private let db = Firestore.firestore()
    
    func allUsers() async -> [User] {
        let query = try? await db.collection(Path.users).getDocuments()
        let users = query?.documents.compactMap { try? $0.data(as: User.self) } ?? []
        
        return users
    }
    
}

private struct Path {
    
    static let users = "users"
    
}
