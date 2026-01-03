//
//  LogbookRepositories.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

class LogbookRepository {
    private let api: APIService
    private let storage: LocalStorageProtocol
    
    init(api: APIService = .shared, storage: LocalStorageProtocol = LocalStorage.shared) {
        self.api = api
        self.storage = storage
    }
    
    func fetchLogbooks(page: Int = 1, limit: Int = 10, forceRefresh: Bool = false) async throws -> (logbooks: [Logbook], totalPages: Int) {
        if !forceRefresh, page == 1 {
            let cached = storage.getLogbooks()
            if !cached.isEmpty {
                // Optionally assume totalPages = 1 for cached data
                return (cached, 1)
            }
        }

        let paginatedResponse = try await api.fetchLogbooks(page: page, limit: limit)

        let logbooks = paginatedResponse.logbooks
        let totalPages = paginatedResponse.totalPages

        if page == 1 {
            storage.saveLogbooks(logbooks) // only cache first page
        }

        print("API returned page \(page) with \(paginatedResponse.logbooks.count) items, totalPages: \(paginatedResponse.totalPages)")
        
        return (logbooks, totalPages)
    }

    
    // MARK: - Add Logbook
    func addLogbook(activity: String, durationNumber: Int, durationUnit: String, logDate: Date) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: logDate)

        let request = CreateLogbookRequest(
            activity: activity,
            logDate: dateString,
            durationNumber: durationNumber,
            durationUnit: durationUnit
        )

        try await api.addLogbook(request)
        
        // Refresh cached logbooks
        let updatedLogbooks = try await api.fetchLogbooks().logbooks
        storage.saveLogbooks(updatedLogbooks)
    }

    // MARK: - Update Logbook
    func updateLogbook(logbook: Logbook, activity: String, durationNumber: Int, durationUnit: String, logDate: Date) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: logDate)

        let request = UpdateLogbookRequest(
            activity: activity,
            logDate: dateString,
            durationNumber: durationNumber,
            durationUnit: durationUnit
        )

        try await api.updateLogbook(id: logbook.id, data: request)
        
        // Refresh cached logbooks
        let updatedLogbooks = try await api.fetchLogbooks().logbooks
        storage.saveLogbooks(updatedLogbooks)
    }
    
    // MARK: - Delete Logbook
    func deleteLogbook(_ logbook: Logbook) async throws {
        try await api.deleteLogbook(id: logbook.id)
        
        // Refresh cached logbooks
        let updatedLogbooks = try await api.fetchLogbooks().logbooks
        storage.saveLogbooks(updatedLogbooks)
    }
    
    func getCachedLogbooks() -> [Logbook] {
        storage.getLogbooks()
    }
}
