//
//  SignInView.swift
//  SimpleCalorie
//
//  Created by MK on 13/09/2022.
//

import SwiftUI

struct SignInView: View {
    
    @StateObject var appRepo: ApplicationRepository
    
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                Form {
                    Text(
                    """
                    Welcome to Simple Calorie demo app! There are 2 roles for this app:\n
                    1. Regular user - can read/add/update/delete own food entries
                    2. Admin user - can read/add/update/delete any other user food entries. Has access to reports
                    
                    Sign in with provided credentials:
                    """
                    )
                    
                    Section {
                        TextField(
                            "name@email.com",
                            text: $appRepo.email
                        )
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                        .textContentType(.emailAddress)
                        .tint(.gray)
                        
                        SecureField(
                            "••••••••",
                            text: $appRepo.password
                        )
                    }
                }
                
                AsyncButton(action: appRepo.signIn) {
                    Text("Sign In")
                        .padding()
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .center)
                }
                .background(.blue)
                .disabled(!appRepo.isFormValid)
                .cornerRadius(10)
                .padding()
            }
            .navigationTitle("Simple Calorie")
        }
    }
    
}
