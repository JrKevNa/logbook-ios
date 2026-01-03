//
//  Logbook.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import Foundation

struct Logbook: Codable, Identifiable, Equatable {
    let id: String
    let activity: String
    let durationNumber: Int
    let durationUnit: String
    let logDate: String
    let createdBy: User?
}

struct PaginatedLogbookResponse: Codable {
    let logbooks: [Logbook]
    let totalPages: Int
}

struct CreateLogbookRequest: Codable {
    let activity: String
    let logDate: String   // send as string "YYYY-MM-DD"
    let durationNumber: Int
    let durationUnit: String
}

struct UpdateLogbookRequest: Codable {
    let activity: String
    let logDate: String
    let durationNumber: Int
    let durationUnit: String
}
