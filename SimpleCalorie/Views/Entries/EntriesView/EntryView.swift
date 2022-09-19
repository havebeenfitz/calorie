//
//  EntryView.swift
//  SimpleCalorie
//
//  Created by MK on 17/09/2022.
//

import SwiftUI

struct EntryView: View {
    
    var model: UIEntry
    
    var body: some View {
        HStack {
            let imageEdgeSize = 60.0
            AsyncImage(url: model.imageUrl) { image in
                image
                    .resizable()
                    .clipShape(Circle())
                    .scaledToFill()
                    .padding([.trailing])
                    .frame(width: imageEdgeSize, height: imageEdgeSize)
            } placeholder: {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(.accentColor)
                    .padding([.trailing])
                    .frame(width: imageEdgeSize, height: imageEdgeSize)
            }
            
            let entryKcalValue = "\(Int(model.kCalValue)) kcal"
            
            VStack(alignment: .leading) {
                Text(model.title)
                    .font(.title2)
                    .multilineTextAlignment(.leading)
                Text(entryKcalValue)
                    .font(.subheadline)
                    .foregroundColor(Color.accentColor)
                    .multilineTextAlignment(.leading)
            }
            Spacer(minLength: 10)
            Text(model.date.formatted(date: .omitted, time: .shortened))
                .font(.caption)
        }
    }
    
}
