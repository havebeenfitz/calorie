//
//  EntriesModel.swift
//  SimpleCalorie
//
//  Created by MK on 17/09/2022.
//

import UIKit

final class EntriesModel: ObservableObject {
    
    @Published var entriesListIsLoading: Bool = false
    
    // Filter bindings
    
    @Published var filters: (from: Bool, to: Bool) = (false, false) {
        didSet {
            Task {
                await applyFilters(filters)
            }
        }
    }
    @Published var fromDate: Date = .now
    @Published var toDate: Date = .now
    
    // Sections bindings
    
    @Published var allSections: [UIDaySection] = []
    @Published var filteredSections: [UIDaySection] = []
    @Published var selectedEntry: UIEntry? = nil {
        didSet {
            prefillEntryBindings()
        }
    }
    
    // Add Entry bindings
    
    @Published var entryName: String = ""
    @Published var kCalValue: String = ""
    @Published var date: Date = .now
    @Published var image: UIImage? = nil
    
    // Services & Helpers
    
    private let entriesClient: EntriesClient
    private var initialEntriesDidLoad: Bool = false
    
    private let dayDateFormtter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "D"
        return formatter
    }()
    
    init(entriesClient: EntriesClient) {
        self.entriesClient = entriesClient
    }
    
}

// MARK: - Entries operations

extension EntriesModel {
    
    @MainActor
    func getEntries() async {
        if !initialEntriesDidLoad {
            entriesListIsLoading = true
            initialEntriesDidLoad = true
        }
        
        let entries = (try? await entriesClient.allEntries()) ?? []
        
        let groups = Dictionary(grouping: entries, by: { dayDateFormtter.string(from: $0.date) })
            .sorted(by: { $0.key > $1.key})
            .map(\.value)
        
        allSections = groups.compactMap { entries in
            let sectionDate: Date = entries.first?.date ?? .now
            let entryTitle: String = sectionDate.formatted(date: .abbreviated, time: .omitted)
            
            return UIDaySection(
                id: UUID().uuidString,
                day: sectionDate,
                title: entryTitle,
                progress: entries.reduce(into: 0, { $0 += $1.kCalValue }),
                limit: entriesClient.currentUser?.kCalLimit ?? Const.kCalDefaultLimit,
                entries: entries.map { $0.asUIEntry }.sorted(by: { $0.date > $1.date })
            )
        }
        
        applyFilters(filters)
        
        if entriesListIsLoading {
            entriesListIsLoading = false
        }
    }
    
    func addOrUpdateEntry() async {
        let compressedImageData = image?.jpegData(compressionQuality: 0.5)
        
        if let selectedEntry = selectedEntry {
            await updateEntry(id: selectedEntry.id, title: entryName, kCalValue: kCalValue, date: date, image: compressedImageData)
        } else {
            await addEntry(title: entryName, kCalValue: kCalValue, date: date, image: compressedImageData)
        }
        
        await getEntries()
    }
    
    func deleteEntry(id: String, imageUrl: URL?) async {
        try? await entriesClient.deleteEntry(entryId: id, imageUrl: imageUrl)
        
        await getEntries()
    }
    
}

// MARK: - Filtering

private extension EntriesModel {
    
    @MainActor
    func applyFilters(_ newValue: (from: Bool, to: Bool)) {
        switch newValue {
        case (true, true):
            filteredSections = allSections.filter { section in
                let fromResult = Calendar.current.compare(section.day, to: fromDate, toGranularity: .day)
                let toResult = Calendar.current.compare(section.day, to: toDate, toGranularity: .day)
                
                let includingFrom = fromResult == .orderedDescending || fromResult == .orderedSame
                let includingTo = toResult == .orderedAscending || toResult == .orderedSame
                return includingFrom && includingTo
            }
        case (false, true):
            filteredSections = allSections.filter { section in
                let toResult = Calendar.current.compare(section.day, to: toDate, toGranularity: .day)
                let includingTo = toResult == .orderedAscending || toResult == .orderedSame
                return includingTo
            }
        case (true, false):
            filteredSections = allSections.filter { section in
                let fromResult = Calendar.current.compare(section.day, to: fromDate, toGranularity: .day)
                let includingFrom = fromResult == .orderedDescending || fromResult == .orderedSame
                return includingFrom
            }
        case (false, false):
            filteredSections = allSections
        }
    }
    
}

// MARK: - Private

private extension EntriesModel {
    
    func addEntry(title: String, kCalValue: String, date: Date, image: Data?) async {
        let kCalNumeric = Double(kCalValue.replacing(",", with: ".")) ?? 0
        let entryId = UUID().uuidString
        
        var imageUrl: URL?
        
        if let image = image {
            imageUrl = try? await entriesClient.uploadPhoto(data: image, entryId: entryId)
        }
        
        let entry = Entry(id: entryId, title: title, kCalValue: kCalNumeric, date: date, imageUrl: imageUrl)
        
        try? await entriesClient.addEntry(entry)
    }
    
    func updateEntry(id: String, title: String, kCalValue: String, date: Date, image: Data?) async {
        let kCalNumeric = Double(kCalValue.replacing(",", with: ".")) ?? 0
        
        var imageUrl: URL?
        
        if let image = image {
            imageUrl = try? await entriesClient.uploadPhoto(data: image, entryId: id)
        }
        
        let entry = Entry(id: id, title: title, kCalValue: kCalNumeric, date: date, imageUrl: imageUrl)
        
        try? await entriesClient.updateEntry(id, newEntry: entry)
    }
    
    func prefillEntryBindings() {
        if let selectedEntry {
            entryName = selectedEntry.title
            kCalValue = "\(selectedEntry.kCalValue)"
            date = selectedEntry.date
        } else {
            entryName = ""
            kCalValue = ""
            date = .now
            image = nil
        }
    }
    
}
