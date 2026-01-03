//
//  AppState.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//
import SwiftUI
import KeychainAccess

@MainActor
class AppState: ObservableObject {
    @Published var theme: AppTheme = .system
    @Published var currentUser: User?        // nil if logged out
    @Published var isLoading = false         // optional, for showing global loading
    @Published var errorMessage: String?     // optional, for global alerts
    

    init() {
        loadTheme()
        loadUserFromStorage()
    }

    func loadTheme() {
        if let saved = UserDefaults.standard.string(forKey: "theme"),
           let theme = AppTheme(rawValue: saved) {
            self.theme = theme
        }
    }

    func saveTheme(_ theme: AppTheme) {
        self.theme = theme
        UserDefaults.standard.set(theme.rawValue, forKey: "theme")
    }
    
    func loadUserFromStorage() {
        if let refreshToken = KeychainService.shared.get("refreshToken") {
            Task {
                await refreshAndFetchUser(refreshToken: refreshToken)
            }
        }
    }
        
    func refreshAndFetchUser(refreshToken: String) async {
        do {
            let newAccessToken = try await APIService.shared.refreshToken(refreshToken: refreshToken)

            KeychainService.shared.save("accessToken", value: newAccessToken)

            let user = try await APIService.shared.fetchCurrentUser(accessToken: newAccessToken)

            await MainActor.run {
                self.currentUser = user
            }

        } catch {
            await MainActor.run {
                self.logout()
            }
        }
    }
    
    func logout() {
        KeychainService.shared.delete("accessToken")
        KeychainService.shared.delete("refreshToken")
        currentUser = nil
    }
}
