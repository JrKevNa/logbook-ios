//
//  RoleRepository.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 16/12/25.
//

import SwiftUI

class RoleRepository {
    private let api: APIService
    private let storage: LocalStorageProtocol
    
    init(api: APIService = .shared, storage: LocalStorageProtocol = LocalStorage.shared) {
        self.api = api
        self.storage = storage
    }
    
    func fetchAllRoles() async throws -> ([Role]) {
        let response = try await api.fetchAllRoles()
        let roles = response
        return (roles)
    }
}
