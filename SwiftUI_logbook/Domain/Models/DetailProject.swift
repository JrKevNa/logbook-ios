//
//  DetailProject.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 09/12/25.
//

import Foundation

struct DetailProject: Codable, Equatable {
    let id: String
    let projectId: String
    let workedBy: User
    let requestedBy: String
    let activity: String
    let requestDate: String
    let note: String?
    let isDone: Bool
}

struct PaginatedDetailProjectsResponse: Codable {
    let detailProjects: [DetailProject]
    let totalPages: Int
}

struct CreateDetailProjectRequest: Codable {
    let projectId: String
    let workedById: String
    let requestedBy: String
    let activity: String
    let requestDate: String
    let note: String?
}

struct UpdateDetailProjectRequest: Codable {
    let projectId: String
    let workedById: String
    let requestedBy: String
    let activity: String
    let requestDate: String
    let note: String?
}
