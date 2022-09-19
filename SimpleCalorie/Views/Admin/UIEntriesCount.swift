//
//  UIEntriesCount.swift
//  SimpleCalorie
//
//  Created by MK on 17/09/2022.
//

import Foundation

struct UIEntriesCount: Identifiable {
    
    enum EntryType: String {
        
        case currentWeek = "Current Week"
        case previousWeek = "Previous Week"
        
    }
    
    let id: UUID
    let type: EntryType
    let date: String
    let entriesCount: Int
    
}
