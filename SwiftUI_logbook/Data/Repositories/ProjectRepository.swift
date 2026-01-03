//
//  ProjectRepository.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 08/12/25.
//

import SwiftUI

class ProjectRepository {
    private let api: APIService
    private let storage: LocalStorageProtocol
    
    init(api: APIService = .shared, storage: LocalStorageProtocol = LocalStorage.shared) {
        self.api = api
        self.storage = storage
    }
    
    func fetchProjects(page: Int = 1, limit: Int = 10, forceRefresh: Bool = false) async throws -> (projects: [Project], totalPages: Int) {
        if !forceRefresh, page == 1 {
            let cached = storage.getProjects()
            if !cached.isEmpty {
                // Optionally assume totalPages = 1 for cached data
                return (cached, 1)
            }
        }

        let paginatedResponse = try await api.fetchProjects(page: page, limit: limit)

        let projects = paginatedResponse.projects
        let totalPages = paginatedResponse.totalPages

        if page == 1 {
            storage.saveProjects(projects) // only cache first page
        }

        print("API returned page \(page) with \(paginatedResponse.projects.count) items, totalPages: \(paginatedResponse.totalPages)")
        
        return (projects, totalPages)
    }
    
    func fetchProjectById(id: String) async throws -> (Project) {
        let response = try await api.fetchProjectById(id: id)
        let project = response
//        print("printing users in repository")
//        print(users)
        return (project)
    }
    
    
    // MARK: - Add Project
    func addProject(name: String, startDate: Date, endDate: Date, requestedBy: String, workedById: String) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateStringStartDate = formatter.string(from: startDate)
        let dateStringEndDate = formatter.string(from: endDate)
        
        let request = CreateProjectRequest(
            requestedBy: requestedBy,
            workedById: workedById,
            name: name,
            startDate: dateStringStartDate,
            endDate: dateStringEndDate,
        )

        try await api.addProject(request)
        
        // Refresh cached logbooks
        let updatedProjects = try await api.fetchProjects().projects
        storage.saveProjects(updatedProjects)
    }
    
    // MARK: - Edit Project
    func updateProject(project: Project, name: String, startDate: Date, endDate: Date, requestedBy: String, workedById: String) async throws {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        let dateStringStartDate = formatter.string(from: startDate)
        let dateStringEndDate = formatter.string(from: endDate)
        
        let request = UpdateProjectRequest(
            requestedBy: requestedBy,
            workedById: workedById,
            name: name,
            startDate: dateStringStartDate,
            endDate: dateStringEndDate,
        )

        try await api.updateProject(id: project.id, data: request)
        
        // Refresh cached logbooks
        let updatedProjects = try await api.fetchProjects().projects
        storage.saveProjects(updatedProjects)
    }
}
    
