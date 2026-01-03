//
//  UserRepository.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 08/12/25.
//

import SwiftUI

class UserRepository {
    private let api: APIService
    private let storage: LocalStorageProtocol
    
    init(api: APIService = .shared, storage: LocalStorageProtocol = LocalStorage.shared) {
        self.api = api
        self.storage = storage
    }
    
    func fetchUsers(page: Int = 1, limit: Int = 10, forceRefresh: Bool = false) async throws -> (users: [User], totalPages: Int) {
        if !forceRefresh, page == 1 {
            let cached = storage.getUsers()
            if !cached.isEmpty {
                // Optionally assume totalPages = 1 for cached data
                return (cached, 1)
            }
        }

        let paginatedResponse = try await api.fetchUsers(page: page, limit: limit)

        let users = paginatedResponse.users
        let totalPages = paginatedResponse.totalPages

        if page == 1 {
            storage.saveUsers(users) // only cache first page
        }

        print("API returned page \(page) with \(paginatedResponse.users.count) items, totalPages: \(paginatedResponse.totalPages)")
        
        return (users, totalPages)
    }
    
    // MARK: - Add User
    func addUser(username: String, nik: String, email: String, roleId: String, password: String) async throws {
        let request = CreateUserRequest(
            username: username,
            nik: nik,
            email: email,
            roleId: roleId,
            password: password
        )

        try await api.addUser(request)
        
        // Refresh cached users
        let updatedUsers = try await api.fetchUsers().users
        storage.saveUsers(updatedUsers)
    }
    
    // MARK: - Update Logbook
    func updateUser(user: User, username: String, nik: String, email: String, roleId: String, password: String?) async throws {
        // Only pass password if it’s non-empty
        let passwordToSend = (password?.isEmpty ?? true) ? nil : password

        let request = UpdateUserRequest(
            username: username,
            nik: nik,
            email: email,
            roleId: roleId,
            password: passwordToSend
        )

        try await api.updateUser(id: user.id, data: request)
        
        // Refresh cached users
        let updatedUsers = try await api.fetchUsers().users
        storage.saveUsers(updatedUsers)
    }
    
    func fetchAllUsers() async throws -> ([User]) {
        let response = try await api.fetchAllUsers()
        let users = response
//        print("printing users in repository")
//        print(users)
        return (users)
    }
    
    func updateUserProfile(user: User, username: String) async throws {
        let request = UpdateUserProfileRequest(
            username: username,
        )

        try await api.updateUserProfile(id: user.id, data: request)
    }
    
    func updateUserProfilePassword(oldPassword: String, newPassword: String) async throws {
//        let request = UpdateUserProfileRequest(
//            username: username,
//        )
//
//        try await api.updateUserProfile(id: user.id, data: request)
    }
}
