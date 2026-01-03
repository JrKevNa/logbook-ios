//
//  UserReport.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 12/12/25.
//

import Foundation

struct UserReport: Codable, Identifiable, Equatable {
    var id: String { user.id }
    let user: User
    let entries: [UserEntry]
}

struct UserEntry: Codable, Identifiable, Equatable {
    let id: String
    let activity: String
    let durationNumber: Int
    let durationUnit: String
    let logDate: String?
}
