//
//  User.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

struct User: Codable, Equatable, Hashable {
    let id: String
    let nik: String?
    let email: String?
    let username: String
    let company: Company?
    let userRoles: [UserRole]?;
}

extension User {
    var isAdmin: Bool {
        userRoles?.contains { $0.role.name == "admin" } == true
    }
}

struct PaginatedUsersResponse: Codable {
    let users: [User]
    let totalPages: Int
}

struct CreateUserRequest: Codable {
    let username: String
    let nik: String
    let email: String   // send as string "YYYY-MM-DD"
    let roleId: String
//    let password: String
}

struct UpdateUserRequest: Codable {
    let username: String
    let nik: String
    let email: String   // send as string "YYYY-MM-DD"
    let roleId: String
//    let password: String?
}


struct MeResponse: Codable {
    let user: User
}

struct AllUsersResponse: Codable {
    let users: [User]
}

struct UpdateUserProfileRequest: Codable {
    let username: String
}
