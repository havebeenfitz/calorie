//
//  EntriesClient.swift
//  SimpleCalorie
//
//  Created by MK on 14/09/2022.
//

import Foundation

protocol EntriesClient {
    
    var currentUser: User? { get }
    
    func setNewUser(_ user: User?)
    
    func allEntries(of overrideUserId: String?) async throws -> [Entry]
    func uploadPhoto(data: Data, entryId: String) async throws -> URL
    func addEntry(_ entry: Entry) async throws
    func updateEntry(_ entryId: String, newEntry: Entry) async throws
    func deleteEntry(entryId: String, imageUrl: URL?) async throws
    
}

extension EntriesClient {
    
    func allEntries() async throws -> [Entry] {
        try await allEntries(of: nil)
    }
    
}
