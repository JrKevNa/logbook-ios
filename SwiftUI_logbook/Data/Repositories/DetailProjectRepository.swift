//
//  DetailProjectRepository.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 09/12/25.
//

import SwiftUI

class DetailProjectRepository {
    private let api: APIService
    private let storage: LocalStorageProtocol
    
    init(api: APIService = .shared, storage: LocalStorageProtocol = LocalStorage.shared) {
        self.api = api
        self.storage = storage
    }
    
    func fetchDetailProjects(id: String, page: Int = 1, limit: Int = 10, forceRefresh: Bool = false) async throws -> (detailProjects: [DetailProject], totalPages: Int) {
        if !forceRefresh, page == 1 {
            let cached = storage.getDetailProjects()
            if !cached.isEmpty {
                // Optionally assume totalPages = 1 for cached data
                return (cached, 1)
            }
        }

        let paginatedResponse = try await api.fetchDetailProjects(id: id, page: page, limit: limit)

        let detailProjects = paginatedResponse.detailProjects
        let totalPages = paginatedResponse.totalPages

        if page == 1 {
            storage.saveDetailProjects(detailProjects) // only cache first page
        }

        print("API returned page \(page) with \(paginatedResponse.detailProjects.count) items, totalPages: \(paginatedResponse.totalPages)")
        
        return (detailProjects, totalPages)
    }
    
    // MARK: - Add Detail Project
    func addDetailProject(projectId: String, activity: String, requestDate: Date, requestedBy: String, workedById: String, note: String?) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateStringRequestDate = formatter.string(from: requestDate)
        
        let request = CreateDetailProjectRequest(
            projectId: projectId,
            workedById: workedById,
            requestedBy: requestedBy,
            activity: activity,
            requestDate: dateStringRequestDate,
            note: note
        )

        try await api.addDetailProject(request)
        
        // Refresh cached logbooks
        let updatedDetailProjects = try await api.fetchDetailProjects(id: projectId).detailProjects
        storage.saveDetailProjects(updatedDetailProjects)
    }
    
    // MARK: - Update Detail Project
    func updateDetailProject(detailProject: DetailProject, projectId: String, activity: String, requestDate: Date, requestedBy: String, workedById: String, note: String?) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateStringRequestDate = formatter.string(from: requestDate)
        
        let request = UpdateDetailProjectRequest(
            projectId: projectId,
            workedById: workedById,
            requestedBy: requestedBy,
            activity: activity,
            requestDate: dateStringRequestDate,
            note: note
        )

        try await api.updateDetailProject(id: detailProject.id, data: request)
        
        // Refresh cached logbooks
        let updatedDetailProjects = try await api.fetchDetailProjects(id: projectId).detailProjects
        storage.saveDetailProjects(updatedDetailProjects)
    }
}
