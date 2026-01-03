//
//  ToDoList.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 05/12/25.
//

import Foundation

struct ToDoList: Codable, Identifiable, Equatable {
    let id: String
    let createDate: Date
    let activity: String
    let isDone: Bool
    let createdBy: User?
}

struct PaginatedToDoListResponse: Codable {
    let toDoList: [ToDoList]
    let totalPages: Int
}

struct CreateToDoRequest: Codable {
    let activity: String
}

struct UpdateToDoRequest: Codable {
    let activity: String
}

struct FinishToDoRequest: Codable {
    let isDone: Bool
}
