//
//  AddEntryButtonView.swift
//  SimpleCalorie
//
//  Created by MK on 17/09/2022.
//

import SwiftUI

struct AddEntryButtonView: View {
    
    @ObservedObject var model: EntriesModel
    
    @State var isPresented: Bool = false
    
    var body: some View {
        Button(
            action: {
                isPresented = true
            }, label: {
                let buttonEdgeSize = 70.0
                Image(systemName: "plus")
                    .resizable()
                    .padding()
                    .background(.blue)
                    .foregroundColor(.white)
                    .cornerRadius(buttonEdgeSize / 2)
                    .frame(width: buttonEdgeSize, height: buttonEdgeSize)
            }
        )
        .foregroundColor(.accentColor)
        .sheet(
            isPresented: $isPresented,
            onDismiss: {
                isPresented = false
            }, content: {
                EntrySheetView(
                    model: model,
                    isPresented: $isPresented
                )
                .padding()
                .presentationDetents([.height(350)])
                .presentationDragIndicator(.visible)
                .onDisappear {
                    model.selectedEntry = nil
                }
            }
        )
    }
}
