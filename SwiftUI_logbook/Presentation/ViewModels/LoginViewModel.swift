//
//  LoginViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//
import SwiftUI

@MainActor
class LoginViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var user: User?

    private var appState: AppState   // <- reference the shared instance

    init(appState: AppState) {
        self.appState = appState
    }

    func login() async {
        isLoading = true
        errorMessage = nil
        do {
            let loggedInUser = try await APIService.shared.login(email: email, password: password)
            self.user = loggedInUser
            appState.currentUser = loggedInUser   // update shared app state
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}
