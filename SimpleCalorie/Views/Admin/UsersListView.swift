//
//  UsersListView.swift
//  SimpleCalorie
//
//  Created by MK on 16/09/2022.
//

import SwiftUI

struct UsersListView: View {
    
    @EnvironmentObject var appRepo: ApplicationRepository
    @ObservedObject var model: AdminModel
    
    var body: some View {
        ZStack {
            List(model.users) { user in
                NavigationLink {
                    EntriesListView(
                        model: appRepo.entriesModel,
                        adminMode: appRepo.adminMode
                    )
                    .onAppear {
                        appRepo.selectUser(user)
                    }
                    .onDisappear {
                        appRepo.selectUser(nil)
                    }
                } label: {
                    VStack(alignment: .leading) {
                        Text("User with id:")
                            .bold()
                        Text("\(user.id)")
                            .italic()
                    }
                    .frame(height: 80)
                }
            }
            .opacity(model.usersListIsLoading ? 0 : 1)
            
            if model.usersListIsLoading {
                ProgressView { Text("Users list loading...") }
            }
        }
        .navigationTitle("All Users")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    appRepo.signOut()
                } label: {
                    Image(systemName: "door.right.hand.open")
                        .foregroundColor(.accentColor)
                }
            }
        }
        .onAppear {
            Task {
                await model.getAllUsers()
            }
        }
        .refreshable {
            Task {
                await model.getAllUsers(force: true)
            }
        }

    }
    
}
