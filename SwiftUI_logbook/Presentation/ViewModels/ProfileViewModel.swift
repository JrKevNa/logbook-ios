//
//  ProfileViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 15/12/25.
//

import SwiftUI

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var username: String = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var errorMessageForPassword: String?
    @Published var showSuccessAlert = false
    
    @Published var oldPassword = ""
    @Published var newPassword = ""
    @Published var confirmPassword = ""
    
    @Published var user: User?
    
    private let appState: AppState
    private let repository: UserRepository
    
    init(appState: AppState, repository: UserRepository = UserRepository()) {
        self.repository = repository
        self.appState = appState
        self.user = appState.currentUser
        self.username = appState.currentUser?.username ?? ""
    }
    
    func saveUsername() async {
        guard let user = user else { return }
        isLoading = true
        errorMessage = nil
        
        do {
            try await repository.updateUserProfile(user: user, username: username)
            appState.loadUserFromStorage()
            showSuccessAlert = true 
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func updatePassword() async {
        isLoading = true
        errorMessage = nil
        
        // 1. basic validation
        guard !oldPassword.isEmpty,
              !newPassword.isEmpty,
              !confirmPassword.isEmpty else {
            errorMessage = "Please fill all fields"
            return
        }

        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match"
            return
        }
        
        do {
            try await repository.updateUserProfilePassword(oldPassword: oldPassword, newPassword: newPassword)
//            appState.loadUserFromStorage()
            showSuccessAlert = true
        } catch {
            self.errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
