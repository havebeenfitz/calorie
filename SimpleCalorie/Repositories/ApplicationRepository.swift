//
//  ApplicationStore.swift
//  SimpleCalorie
//
//  Created by MK on 14/09/2022.
//

import Foundation

final class ApplicationRepository: ObservableObject {
    
    // MARK: - Main State
    
    @Published var entriesModel: EntriesModel
    @Published var adminModel: AdminModel
    
    // MARK: Publisers
    
    @Published var email: String = ""
    @Published var password: String = ""
    
    // MARK: - User observers
    
    @Published var currentUser: User? {
        didSet {
            if !adminMode {
                entriesClient.setNewUser(currentUser)
            }
        }
    }
    @Published var selectedUser: User? {
        didSet {
            entriesClient.setNewUser(selectedUser)
        }
    }
    
    var isAuthorized: Bool {
        authClient.currentUser != nil
    }
    
    var adminMode: Bool {
        authClient.currentUser?.isAdmin ?? false
    }
    
    var isFormValid: Bool {
        get {
            let name = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
            let domain = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
            let emailRegEx = name + "@" + domain + "[A-Za-z]{2,8}"
            let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegEx)
            
            let isEmailValid = emailPredicate.evaluate(with: self.email)
            
            return isEmailValid && !password.isEmpty
        }
    }
    
    private let authClient: AuthClient
    private let userClient: UserClient
    private let entriesClient: EntriesClient
    
    // MARK: - Initializers
    
    init(
        authClient: AuthClient,
        userClient: UserClient,
        entriesClient: EntriesClient
    ) {
        self.authClient = authClient
        self.userClient = userClient
        self.entriesClient = entriesClient
        
        self.entriesModel = EntriesModel(entriesClient: entriesClient)
        self.adminModel = AdminModel(userClient: userClient, entriesClient: entriesClient)
    }
    
    // MARK: - Methods
    
    @MainActor
    func signIn() async {
        guard isFormValid else { return }
        
        currentUser = await authClient.signIn(email: email, password: password)
    }
    
    func signOut() {
        currentUser = nil
        authClient.signOut()
    }
    
    func selectUser(_ user: User?) {
        selectedUser = user
    }
    
}
