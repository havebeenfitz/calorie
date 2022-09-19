//
//  EntriesListView.swift
//  SimpleCalorie
//
//  Created by MK on 13/09/2022.
//

import SwiftUI

struct EntriesListView: View {
    
    @EnvironmentObject var appRepo: ApplicationRepository
    @ObservedObject var model: EntriesModel
    
    var adminMode: Bool
    
    var body: some View {
        ZStack(alignment: .bottom) {
            if model.entriesListIsLoading {
                ProgressView { Text("Loading entries...") }
            } else {
                List {
                    FiltersView(model: model)
                    EntriesSectionView(model: model)
                }
                .listStyle(.sidebar)
                
                AddEntryButtonView(model: model)
            }
        }
        .toolbar(.hidden, for: .tabBar)
        .toolbar {
            if !adminMode {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        appRepo.signOut()
                    } label: {
                        Image(systemName: "door.right.hand.open")
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .navigationTitle("Daily Entries")
        .refreshable {
            Task {
                await model.getEntries()
            }
        }
        .onAppear {
            Task {
                await model.getEntries()
            }
        }
    }
    
}
