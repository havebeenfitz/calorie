//
//  UserClient.swift
//  SimpleCalorie
//
//  Created by MK on 16/09/2022.
//

import Foundation

protocol UserClient {
    
    func allUsers() async -> [User]
    
}
