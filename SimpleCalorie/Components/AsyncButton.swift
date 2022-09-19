//
//  AsyncButton.swift
//  SimpleCalorie
//
//  Created by MK on 15/09/2022.
//

import SwiftUI

struct AsyncButton<Label: View>: View {
    
    var action: () async -> Void
    var actionOptions = Set(ActionOption.allCases)
    
    @ViewBuilder var label: () -> Label
    
    @State private var isDisabled = false
    @State private var showProgressView = false
    
    var body: some View {
        Button(
            action: {
                if actionOptions.contains(.disableButton) {
                    isDisabled = true
                }
                
                if actionOptions.contains(.showProgressView) {
                    showProgressView = true
                }
                
                Task {
                    await action()
                    isDisabled = false
                    showProgressView = false
                }
            },
            label: {
                ZStack {
                    label().opacity(showProgressView ? 0 : 1)

                    if showProgressView {
                        ProgressView()
                    }
                }
            }
        )
        .background(isDisabled ? .gray : .accentColor)
        .disabled(isDisabled)
    }
    
}

// MARK: - Subtypes

extension AsyncButton {
    
    enum ActionOption: CaseIterable {
        case disableButton
        case showProgressView
    }
    
}
