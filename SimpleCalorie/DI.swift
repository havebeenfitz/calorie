//
//  DI.swift
//  SimpleCalorie
//
//  Created by MK on 15/09/2022.
//

import SwiftUI
import FirebaseFirestore
import FirebaseFirestoreSwift

final class DI {
    
    static let authClient: AuthClient = FirebaseAuthClient()
    static let userClient: UserClient = FirebaseUserClient()
    static let entriesClient: EntriesClient = FirebaseEntriesClient()

    static let appRepo = ApplicationRepository(
        authClient: authClient,
        userClient: userClient,
        entriesClient: entriesClient
    )

}
