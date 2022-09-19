//
//  Entry.swift
//  SimpleCalorie
//
//  Created by MK on 14/09/2022.
//

import Foundation

struct Entry: Codable, Equatable {
    
    let id: String
    let title: String
    let kCalValue: Double
    let date: Date
    let imageUrl: URL?
    
    init(
        id: String = UUID().uuidString,
        title: String,
        kCalValue: Double,
        date: Date,
        imageUrl: URL?
    ) {
        self.id = id
        self.title = title
        self.kCalValue = kCalValue
        self.date = date
        self.imageUrl = imageUrl
    }
    
}
