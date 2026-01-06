//
//  AddUserViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 16/12/25.
//

import SwiftUI

@MainActor
class AddUserViewModel: ObservableObject {
    var mode: ModalMode = .add
    @Published var roles: [Role] = []
    
    @Published var username = ""
    @Published var nik = ""
    @Published var email = ""
    @Published var selectedRole: Role? = nil
//    @Published var password = ""
//    @Published var confirmPassword = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: UserRepository
    private let roleRepository: RoleRepository
    var userToEdit: User?
    var dismiss: (() -> Void)?
    
    init(mode: ModalMode = .add, user: User? = nil, repository: UserRepository = UserRepository(), roleRepository: RoleRepository = RoleRepository()) {
        self.mode = mode
        self.repository = repository
        self.roleRepository = roleRepository
        self.userToEdit = user

        if let user = user {
            self.username = user.username
            self.nik = user.nik ?? ""
            self.email = user.email ?? ""
        }
        
        Task {
            await self.loadRoles()
        }
    }
    
    func loadRoles() async {
        do {
            self.roles = try await roleRepository.fetchAllRoles()
            
            if let existing = userToEdit?.userRoles?.first?.role {
                // Match by ID instead of instance
                self.selectedRole = self.roles.first { $0.id == existing.id }
            }
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func save() async -> Bool {
        isLoading = true
        
        // MARK: - Validation
        if username.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Username cannot be empty"
            isLoading = false
            return false
        }
        
        if email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Email cannot be empty"
            isLoading = false
            return false
        }
        
        if nik.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty  {
            errorMessage = "NIK can't be empty"
            isLoading = false
            return false
        }
        
        if selectedRole == nil {
            errorMessage = "Please select a user role"
            isLoading = false
            return false
        }
        
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch mode {
            case .add:
//                guard password == confirmPassword else {
//                    errorMessage = "Passwords do not match"
//                    isLoading = false
//                    return false
//                }
                
                try await self.repository.addUser(
                    username: self.username,
                    nik: self.nik,
                    email: self.email,
                    roleId: self.selectedRole!.id ?? "",
                    // password: self.password
                )
                
            case .edit:
//                guard password == confirmPassword else {
//                    errorMessage = "Passwords do not match"
//                    isLoading = false
//                    return false
//                }
                
                // let passwordToUpdate: String? = self.password.isEmpty ? nil : self.password
                
                try await self.repository.updateUser(
                    user: userToEdit!,
                    username: self.username,
                    nik: self.nik,
                    email: self.email,
                    roleId: self.selectedRole?.id ?? "",
                    // password: passwordToUpdate // nil if empty
                )
                
            default :
                return false
            }
            return true
        } catch {
            errorMessage = error.localizedDescription
        }
        return false
    }
}
