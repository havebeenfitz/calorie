//
//  User.swift
//  SimpleCalorie
//
//  Created by MK on 14/09/2022.
//

import Foundation
import FirebaseFirestoreSwift

struct User: Codable, Identifiable, Hashable {
    
    let id: String
    let isAdmin: Bool
    let kCalLimit: Double
    
    init(id: String, isAdmin: Bool, kCalLimit: Double) {
        self.id = id
        self.isAdmin = isAdmin
        self.kCalLimit = kCalLimit
    }
    
}
