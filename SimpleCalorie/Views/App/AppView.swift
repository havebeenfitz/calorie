//
//  AppView.swift
//  SimpleCalorie
//
//  Created by MK on 13/09/2022.
//

import SwiftUI

struct AppView: View {
    
    @EnvironmentObject var appRepo: ApplicationRepository
    
    var body: some View {
        if appRepo.isAuthorized, appRepo.adminMode {
            AdminTabView(model: appRepo.adminModel)
                .environmentObject(appRepo)
        } else if appRepo.isAuthorized {
            NavigationStack {
                EntriesListView(
                    model: appRepo.entriesModel,
                    adminMode: appRepo.adminMode
                )
                .environmentObject(appRepo)
            }
        } else {
            SignInView(appRepo: appRepo)
        }
    }
}
