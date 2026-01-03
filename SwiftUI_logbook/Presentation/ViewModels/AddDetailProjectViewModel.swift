//
//  AddDetailProjectViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 09/12/25.
//

import SwiftUI

@MainActor
class AddDetailProjectViewModel: ObservableObject {
    var mode: ModalMode = .add
    @Published var users: [User] = []
    var projectId = ""
    
    @Published var activity = ""
    @Published var requestDate = Date()
    @Published var requestedBy = ""
    @Published var workedBy: User?
    @Published var isDone = false
    @Published var note = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: DetailProjectRepository
    private let userRepository: UserRepository
    var detailProjectToEdit: DetailProject?
    var dismiss: (() -> Void)?
    
    init(mode: ModalMode = .add, detailProject: DetailProject? = nil, projectId: String = "", repository: DetailProjectRepository = DetailProjectRepository(), userRepository: UserRepository = UserRepository()) {
        self.mode = mode
        self.repository = repository
        self.userRepository = userRepository
        self.detailProjectToEdit = detailProject
        self.projectId = projectId

        if let detailProject = detailProject {
            self.activity = detailProject.activity
            self.requestedBy = detailProject.requestedBy
            self.isDone = detailProject.isDone
            self.note = detailProject.note ?? ""
            
            // Convert logDate string to Date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd" // match your JSON format
            
            if let date = formatter.date(from: detailProject.requestDate) {
                requestDate = date
            } else {
                requestDate = Date() // fallback to today if parsing fails
            }
        }
        
        Task {
            await self.loadUsers()
        }
    }
    
    func loadUsers() async {
        do {
            self.users = try await userRepository.fetchAllUsers()

            if let existing = detailProjectToEdit {
                self.workedBy = users.first(where: { $0.id == existing.workedBy.id })
            }

        } catch {
            self.errorMessage = error.localizedDescription
        }
    }
    
    func save() async -> Bool {
        // MARK: - Validation
        if activity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            errorMessage = "Activity cannot be empty"
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
        
        if requestDate > Date() {
            errorMessage = "Request date cannot be in the future"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            switch mode {
            case .add:
                try await self.repository.addDetailProject(projectId: self.projectId, activity: self.activity, requestDate: self.requestDate, requestedBy: self.requestedBy, workedById: self.workedBy?.id ?? "", note: self.note)

            case .edit:
                guard let detailProjectToEdit else { throw NSError(domain: "ToDo", code: 0) }
                try await self.repository.updateDetailProject(detailProject: detailProjectToEdit, projectId: self.projectId, activity: self.activity, requestDate: self.requestDate, requestedBy: self.requestedBy, workedById: self.workedBy?.id ?? "", note: self.note)
            
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
