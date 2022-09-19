//
//  FiltersView.swift
//  SimpleCalorie
//
//  Created by MK on 17/09/2022.
//

import SwiftUI

struct FiltersView: View {
    
    @ObservedObject var model: EntriesModel
    
    var body: some View {
        Section("Fitler By Date") {
            VStack {
                filterView(stateBinding: $model.filters.from, dateBinding: $model.fromDate, text: "From")
                filterView(stateBinding: $model.filters.to, dateBinding: $model.toDate, text: "To")
            }
        }
    }

    func filterView(
        stateBinding: Binding<Bool>,
        dateBinding: Binding<Date>,
        text: String
    ) -> some View {
        HStack {
            DatePicker(selection: dateBinding, displayedComponents: [.date]) {
                Text(text).font(.subheadline)
            }
            Toggle("", isOn: stateBinding)
                .frame(width: 50)
        }
        .frame(height: 40)
    }
}

