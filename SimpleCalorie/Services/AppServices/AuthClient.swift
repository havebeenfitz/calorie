//
//  AuthClient.swift
//  SimpleCalorie
//
//  Created by MK on 14/09/2022.
//

import Foundation

protocol AuthClient {
    
    var currentUser: User? { get }
    
    func signIn(email: String, password: String) async -> User?
    func signOut()
    
}
