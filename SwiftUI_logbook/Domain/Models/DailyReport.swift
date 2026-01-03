//
//  DailyReport.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 10/12/25.
//

import Foundation

struct DailyReport: Codable, Identifiable, Equatable {
    var id: String { date } 
    let date: String
    let entries: [DailyEntry]
}

struct DailyEntry: Codable, Identifiable, Equatable {
    let id: String
    let activity: String
    let durationNumber: Int
    let durationUnit: String
    let createdBy: User?
}
