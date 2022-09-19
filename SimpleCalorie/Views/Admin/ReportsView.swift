//
//  ReportsView.swift
//  SimpleCalorie
//
//  Created by MK on 16/09/2022.
//

import SwiftUI
import Charts

struct ReportsView: View {
    
    @EnvironmentObject var appRepo: ApplicationRepository
    @ObservedObject var model: AdminModel
    
    @State var reportType: ReportType = .entriesCount
    
    var body: some View {
        ZStack {
            VStack {
                Picker("Report type", selection: $reportType) {
                    Text("Entries count daily").tag(ReportType.entriesCount)
                    Text("Per user daily average").tag(ReportType.perUserAverage)
                }
                .pickerStyle(.segmented)
                .padding()
                
                switch reportType {
                case .entriesCount:
                    Chart {
                        ForEach(model.entriesCountData) { day in
                            BarMark(
                                x: .value("Entry Count", day.entriesCount),
                                y: .value("Date", day.date),
                                stacking: .normalized
                            )
                            .foregroundStyle(by: .value("Entry Type", day.type.rawValue))
                            .annotation(position: .topTrailing) {
                                Text("\(day.entriesCount)")
                                    .font(.caption2)
                                    .bold()
                                    .foregroundColor(.gray)
                            }
                                
                        }
                    }
                    .chartXAxis(.hidden)
                    .padding()
                    .listRowSeparator(.hidden)
                case .perUserAverage:
                    Chart(model.averageIntakeData) { item in
                        BarMark(
                            x: .value("Average kcal", item.averageKcal),
                            y: .value("Day", item.date)
                        )
                        .foregroundStyle(.orange)
                        .annotation(position: .trailing) {
                            Text("\(item.averageKcal)")
                                .font(.caption2)
                                .bold()
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .listRowSeparator(.hidden)
                }
            }
            .opacity(model.reportsIsLoading ? 0 : 1)
            
            if model.reportsIsLoading {
                ProgressView { Text("Reports loading...") }
            }
        }

        .listStyle(.plain)
        .navigationTitle("Reports")
        .onAppear {
            Task {
                await model.reloadReports()
            }
        }
    }
}

enum ReportType {
    
    case entriesCount
    case perUserAverage
    
}
