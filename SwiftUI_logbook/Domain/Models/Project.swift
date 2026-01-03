//
//  Project.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 08/12/25.
//

import Foundation

struct Project: Codable, Equatable {
    let id: String
    let workedBy: User
    let requestedBy: String;
    let name: String
    let startDate: String
    let endDate: String
    let isDone: Bool
}

struct PaginatedProjectsResponse: Codable {
    let projects: [Project]
    let totalPages: Int
}

struct CreateProjectRequest: Codable {
    let requestedBy: String
    let workedById: String
    let name: String
    let startDate: String
    let endDate: String
}

struct UpdateProjectRequest: Codable {
    let requestedBy: String
    let workedById: String
    let name: String
    let startDate: String
    let endDate: String
}
