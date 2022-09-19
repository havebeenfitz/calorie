//
//  AdminModel.swift
//  SimpleCalorie
//
//  Created by MK on 17/09/2022.
//

import Foundation
import Collections

class AdminModel: ObservableObject {
    
    // MARK: - Published
    
    @Published var usersListIsLoading: Bool = false
    @Published var reportsIsLoading: Bool = false
    
    @Published var users: [User] = []
    @Published var entriesCountData: [UIEntriesCount] = []
    @Published var averageIntakeData: [UIAverageIntake] = []
    
    // MARK: - Private
    
    private let userClient: UserClient
    private let entriesClient: EntriesClient
    
    private var entriesMap: [User: [Entry]] = [:]
    private let sevenDaysInSeconds: TimeInterval = 604800.0
    private let dayGroupingDateFormtter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "D"
        return formatter
    }()
    
    private var initialUsersListDidLoad: Bool = false
    private var initailReportsDidLoad: Bool = false
    
    // MARK: - Init
    
    init(userClient: UserClient, entriesClient: EntriesClient) {
        self.userClient = userClient
        self.entriesClient = entriesClient
    }
    
    // MARK: - Methods
    
    func getAllUsers(force: Bool = false) async {
        if !initialUsersListDidLoad || force {
            usersListIsLoading = true
            users = await userClient.allUsers()
            initialUsersListDidLoad = true
        }
        
        if usersListIsLoading {
            usersListIsLoading = false
        }
    }
    
    func reloadReports() async {
        if !initailReportsDidLoad {
            reportsIsLoading = true
            initailReportsDidLoad = true
        }
        
        await getAllUsersEntries()
        
        makeEntriesCountChartData()
        makeUserAverageChartData()
        
        if reportsIsLoading {
            reportsIsLoading = false
        }
    }
    
}

// MARK: - Private

private extension AdminModel {
    
    func getAllUsersEntries() async {
        for await tuple in userEntriesStream(users: users) {
            entriesMap[tuple.user] = tuple.entries
        }
        
        for key in entriesMap.keys {
            print(key)
            print(entriesMap.values)
        }
    }
    
    func makeEntriesCountChartData() {
        var current: [String: Int] = [:]
        var previous: [String: Int] = [:]
        
        for entries in entriesMap.values {
            let weekMark = Date.now.addingTimeInterval(-sevenDaysInSeconds)
            let twoWeeksMark = Date.now.addingTimeInterval(-2 * sevenDaysInSeconds)
            
            let weekMarkString = dayGroupingDateFormtter.string(from: weekMark)
            let twoWeeksMarkString = dayGroupingDateFormtter.string(from: twoWeeksMark)
            
            Dictionary(grouping: entries, by: { dayGroupingDateFormtter.string(from: $0.date) })
                .filter({ $0.key > weekMarkString })
                .forEach { _, entries in
                    let dateString = (entries.first?.date ?? .now).formatted(date: .abbreviated, time: .omitted)
                    
                    current[dateString] = (current[dateString] ?? 0) + entries.count
                }
            
            Dictionary(grouping: entries, by: { dayGroupingDateFormtter.string(from: $0.date) })
                .filter({ $0.key > twoWeeksMarkString && $0.key <= weekMarkString })
                .forEach { _, entries in
                    let dateString = (entries.first?.date.addingTimeInterval(sevenDaysInSeconds) ?? .now)
                        .formatted(date: .abbreviated, time: .omitted)
                    
                    previous[dateString] = (previous[dateString] ?? 0) + entries.count
                }
        }
        
        let currentWeekEntries = current.map { key, value in
            UIEntriesCount(id: UUID(), type: .currentWeek, date: key, entriesCount: value)
        }
        
        let previousWeekEntries = previous.map { key, value in
            UIEntriesCount(id: UUID(), type: .previousWeek, date: key, entriesCount: value)
        }
        
        self.entriesCountData = (currentWeekEntries + previousWeekEntries).sorted(by: { $0.date > $1.date })
    }
    
    func makeUserAverageChartData() {
        var userCountByDay: [String: Int] = [:]
        var totalKcalByDay: [String: Double] = [:]
        
        for entries in entriesMap.values {
            let weekMark = Date.now.addingTimeInterval(-sevenDaysInSeconds)
            let weekMarkString = dayGroupingDateFormtter.string(from: weekMark)
            
            Dictionary(grouping: entries, by: { dayGroupingDateFormtter.string(from: $0.date) })
                .filter { $0.key > weekMarkString }
                .forEach { _, entries in
                    let dateString = (entries.first?.date ?? .now).formatted(date: .abbreviated, time: .omitted)
                    
                    userCountByDay[dateString] = (userCountByDay[dateString] ?? 0) + 1
                    totalKcalByDay[dateString] = (totalKcalByDay[dateString] ?? 0) + entries.reduce(into: 0, { $0 += $1.kCalValue })
                }
        }
        
        self.averageIntakeData = totalKcalByDay
            .map { day, total in
                let totalKcal = totalKcalByDay[day] ?? 0.0
                let userCount = Double(userCountByDay[day] ?? 1)
                return UIAverageIntake(
                    id: UUID(),
                    date: day,
                    averageKcal: Int(totalKcal / userCount)
                )
            }
            .sorted(by: { $0.date > $1.date })
    }
    
    func userEntriesStream(users: [User]) -> AsyncStream<(user: User, entries: [Entry])> {
        var index = 0
        return AsyncStream { [weak self] in
            guard index < users.count else {
                return nil
            }
            
            let user = users[index]
            index += 1
            
            let entries = (try? await self?.entriesClient.allEntries(of: user.id)) ?? []
            return (user, entries)
        }
    }
    
}
