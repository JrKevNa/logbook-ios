//
//  RegisterViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

class RegisterViewModel: ObservableObject {
    @Published var companyName = ""
    @Published var nik = ""
    @Published var username = ""
    @Published var email = ""
//    @Published var password = ""
//    @Published var confirmPassword = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    @Published var showAlert = false
    @Published var alertMessage = ""
    
    @MainActor
    func register() async {
        isLoading = true
        errorMessage = nil

        // Basic validation
//        guard !username.isEmpty, !email.isEmpty, !password.isEmpty, !confirmPassword.isEmpty else {
//            errorMessage = "All fields are required"
//            isLoading = false
//            return
//        }
        
        guard !companyName.isEmpty, !username.isEmpty, !email.isEmpty else {
            errorMessage = "All fields are required"
            isLoading = false
            return
        }
        
//        guard password == confirmPassword else {
//            errorMessage = "Passwords do not match"
//            isLoading = false
//            return
//        }

        do {
            // Call the API (no need to decode)
            // try await APIService.shared.register(companyName: companyName, username: username, email: email, password: password)
            try await APIService.shared.register(companyName: companyName, nik: nik, username: username, email: email)

            // Show success alert
            alertMessage = "You have been registered successfully!"
            showAlert = true
        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}
