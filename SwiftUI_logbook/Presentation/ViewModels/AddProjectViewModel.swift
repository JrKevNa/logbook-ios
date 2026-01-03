//
//  AddProjectViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 08/12/25.
//

import SwiftUI

@MainActor
class AddProjectViewModel: ObservableObject {
    var mode: ModalMode = .add
    @Published var users: [User] = []
    
    @Published var name = ""
    @Published var startDate = Date()
    @Published var endDate = Date()
    @Published var requestedBy = ""
    @Published var workedBy: User?
    @Published var isDone = false
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: ProjectRepository
    private let userRepository: UserRepository
    var projectToEdit: Project?
    var dismiss: (() -> Void)?
    
    init(mode: ModalMode = .add, project: Project? = nil, repository: ProjectRepository = ProjectRepository(), userRepository: UserRepository = UserRepository()) {
        self.mode = mode
        self.repository = repository
        self.userRepository = userRepository
        self.projectToEdit = project

        if let project = project {
            self.name = project.name
            self.requestedBy = project.requestedBy
            self.isDone = project.isDone
            
            // Convert logDate string to Date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd" // match your JSON format
            
            if let date = formatter.date(from: project.startDate) {
                startDate = date
            } else {
                startDate = Date() // fallback to today if parsing fails
            }
            
            if let date = formatter.date(from: project.endDate) {
                endDate = date
            } else {
                endDate = Date() // fallback to today if parsing fails
            }
        }
        
        Task {
            await self.loadUsers()
        }
    }
    
    func loadUsers() async {
        do {
            self.users = try await userRepository.fetchAllUsers()

            if let existing = projectToEdit {
                self.workedBy = users.first(where: { $0.id == existing.workedBy.id })
            }

        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func save() async -> Bool {
        // MARK: - Validation
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Project name cannot be empty"
            return false
        }
        
        if requestedBy.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Requested By cannot be empty"
            return false
        }
        
        if workedBy == nil {
            errorMessage = "Please select a user for 'Worked By'"
            return false
        }
        
        if endDate < startDate {
            errorMessage = "End date cannot be earlier than start date"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch mode {
            case .add:
                try await self.repository.addProject(name: self.name, startDate: self.startDate, endDate: self.endDate, requestedBy: self.requestedBy, workedById: self.workedBy?.id ?? "")

            case .edit:
                guard let projectToEdit else { throw NSError(domain: "ToDo", code: 0) }
                try await self.repository.updateProject(project: projectToEdit, name: self.name, startDate: self.startDate, endDate: self.endDate, requestedBy: self.requestedBy, workedById: self.workedBy?.id ?? "")
            
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
