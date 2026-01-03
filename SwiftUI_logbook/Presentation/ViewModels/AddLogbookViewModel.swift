//
//  AddLogbookViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 03/12/25.
//
import SwiftUI

@MainActor
class AddLogbookViewModel: ObservableObject {
    var mode: ModalMode = .add
    @Published var activity = ""
    @Published var durationNumber = 0
    @Published var durationUnit = "hours"
    @Published var logDate = Date()
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: LogbookRepository
    var logbookToEdit: Logbook?
    var dismiss: (() -> Void)?

    init(mode: ModalMode = .add, logbook: Logbook? = nil, repository: LogbookRepository = LogbookRepository()) {
        self.mode = mode
        self.repository = repository
        self.logbookToEdit = logbook
        
        if let logbook = logbook {
            activity = logbook.activity
            durationNumber = logbook.durationNumber
            durationUnit = logbook.durationUnit
            
            // Convert logDate string to Date
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd" // match your JSON format
            if let date = formatter.date(from: logbook.logDate) {
                logDate = date
            } else {
                logDate = Date() // fallback to today if parsing fails
            }
        }
    }

    func deleteLogbook() async {
        guard let logbook = logbookToEdit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await self.repository.deleteLogbook(logbook)
            dismiss?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func save() async -> Bool {
        // MARK: - Validation
        guard !activity.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Activity cannot be empty"
            return false
        }

        guard durationNumber > 0 else {
            errorMessage = "Duration must be greater than zero"
            return false
        }

        guard !durationUnit.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            errorMessage = "Please select a duration unit"
            return false
        }

        guard logDate <= Date() else {
            errorMessage = "Log date cannot be in the future"
            return false
        }
        
        isLoading = true
        defer { isLoading = false }

        do {
//            if let logbook = logbookToEdit {
//                try await self.repository.updateLogbook(logbook: logbook, activity: self.activity, durationNumber: self.durationNumber,durationUnit: self.durationUnit,logDate: self.logDate)
//            } else {
//                try await self.repository.addLogbook(activity: self.activity, durationNumber: self.durationNumber,durationUnit: self.durationUnit,logDate: self.logDate)
//            }
            switch mode {
            case .add:
                try await self.repository.addLogbook(activity: self.activity, durationNumber: self.durationNumber,durationUnit: self.durationUnit,logDate: self.logDate)

            case .edit:
                guard let logbookToEdit else { throw NSError(domain: "ToDo", code: 0) }
                try await self.repository.updateLogbook(logbook: logbookToEdit, activity: self.activity, durationNumber: self.durationNumber,durationUnit: self.durationUnit,logDate: self.logDate)
            
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
