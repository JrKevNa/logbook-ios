//
//  UserReportViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 12/12/25.
//

import SwiftUI

@MainActor
class UserReportViewModel: ObservableObject {
    @Published var reports: [UserReport] = []
    @Published var users: [User] = []

    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var selectedUser: User?

    @Published var currentDate = Date()

    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let userRepository = UserRepository()
    private let repository = UserReportRepository()

    func formattedDate(_ date: Date) -> String {
        let df = DateFormatter()
        df.dateStyle = .medium
        return df.string(from: date)
    }

    func formatTime(_ date: Date) -> String {
        let df = DateFormatter()
        df.timeStyle = .short
        return df.string(from: date)
    }

    func goToPreviousDay() {
        let cal = Calendar.current
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            // daily mode
            startDate = cal.date(byAdding: .day, value: -1, to: startDate)!
            endDate = startDate
        } else {
            // range mode → convert to daily
            startDate = cal.date(byAdding: .day, value: -1, to: startDate)!
            endDate = startDate
        }

        Task { await loadReport() }
    }

    func goToNextDay() {
        let cal = Calendar.current
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            // daily mode
            startDate = cal.date(byAdding: .day, value: 1, to: startDate)!
            endDate = startDate
        } else {
            // range mode → convert to daily
            startDate = cal.date(byAdding: .day, value: 1, to: startDate)!
            endDate = startDate
        }

        Task { await loadReport() }
    }
    
    func loadInitial() async {
        await loadUsers()
        await loadReport()
    }

    func loadUsers() async {
        do {
            self.users = try await userRepository.fetchAllUsers()
        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func loadReport() async {
        guard !isLoading else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {

            let response = try await self.repository.fetchUserReport(startDate:  self.startDate, endDate:  self.endDate, userId: self.selectedUser?.id)
        
            // let response = try await repository.fetchLogbooks(page: page, limit: limit, forceRefresh: true)
            
            reports = response
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
}
