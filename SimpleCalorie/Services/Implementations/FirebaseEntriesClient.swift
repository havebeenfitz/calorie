//
//  FirebaseEntriesClient.swift
//  SimpleCalorie
//
//  Created by MK on 14/09/2022.
//

import Combine
import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift
import FirebaseStorage

class FirebaseEntriesClient: EntriesClient {
    
    private(set) var currentUser: User? = nil
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func setNewUser(_ user: User?) {
        self.currentUser = user
    }
    
    func allEntries(of overrideUserId: String?) async throws -> [Entry] {
        var effectiveUserId: String
        
        if let overrideUserId {
            effectiveUserId = overrideUserId
        } else if let userId = currentUser?.id {
            effectiveUserId = userId
        } else {
            throw NetworkError.unauthorized
        }
        
        do {
            let query = try await db.collection("\(Path.entries)/\(effectiveUserId)/\(Path.entries)").getDocuments()
            let entries = query.documents.compactMap { $0.asEntry }
            return entries
        } catch {
            throw NetworkError.serverError
        }
    }
    
    func uploadPhoto(data: Data, entryId: String) async throws -> URL {
        guard let userId = currentUser?.id else {
            throw NetworkError.unauthorized
        }
        
        do {
            let ref = storage.reference(withPath: userId).child("\(entryId).png")
            _ = try await ref.putDataAsync(data)
            let url = try await ref.downloadURL()
            return url
        } catch {
            throw NetworkError.serverError
        }
        
    }
    
    func addEntry(_ entry: Entry) throws {
        guard let userId = currentUser?.id else {
            throw NetworkError.unauthorized
        }
        
        do {
            let docRef = db.document("\(Path.entries)/\(userId)/\(Path.entries)/\(entry.id)")
            try docRef.setData(from: entry)
        } catch {
            throw NetworkError.serverError
        }
    }
    
    func updateEntry(_ entryId: String, newEntry: Entry) throws {
        guard let userId = currentUser?.id else {
            throw NetworkError.unauthorized
        }
        
        do {
            let docRef = db.document("\(Path.entries)/\(userId)/\(Path.entries)/\(entryId)")
            try docRef.setData(from: newEntry)
        } catch {
            throw NetworkError.serverError
        }
    }
    
    func deleteEntry(entryId: String, imageUrl: URL?) async throws {
        guard let userId = currentUser?.id else {
            throw NetworkError.unauthorized
        }
        
        do {
            let docRef = db.document("\(Path.entries)/\(userId)").collection(Path.entries).document(entryId)
            try await docRef.delete()
            if let imageUrl = imageUrl?.absoluteString {
                try await storage.reference(forURL: imageUrl).delete()
            }
        } catch {
            throw NetworkError.serverError
        }
    }
    
}

private struct Path {
    
    static let users = "users"
    static let entries = "entries"
    
}

extension QueryDocumentSnapshot {
    
    var asEntry: Entry? {
        try? data(as: Entry.self)
    }
    
}
