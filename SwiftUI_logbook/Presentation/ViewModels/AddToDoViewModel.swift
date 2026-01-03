//
//  AddToDoViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 05/12/25.
//

import SwiftUI

@MainActor
class AddToDoViewModel: ObservableObject {
    var mode: ModalMode = .add
    @Published var activity = ""
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository: ToDoListRepository
    var todoToEdit: ToDoList?
    var dismiss: (() -> Void)?
    
    init(mode: ModalMode = .add, todo: ToDoList? = nil, repository: ToDoListRepository = ToDoListRepository()) {
        self.mode = mode
        self.repository = repository
        self.todoToEdit = todo
        
        if let todo = todo {
            activity = todo.activity
        }
    }
    
    func deleteToDo() async {
        guard let todo = todoToEdit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await repository.deleteToDo(todo)
            dismiss?()
        } catch {
            errorMessage = error.localizedDescription
        }
    }
    
    func finishToDo() async {
        guard let todo = todoToEdit else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            try await repository.finishToDo(todo)
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
        
        isLoading = true
        defer { isLoading = false }

        do {
            switch mode {
            case .add:
                try await repository.addToDo(activity: activity)

            case .edit:
                guard let todoToEdit else { throw NSError(domain: "ToDo", code: 0) }
                try await repository.updateToDo(toDoList: todoToEdit, activity: activity)
            
            default :
                return false
//            case .finish:
//                guard let todoToEdit else { throw NSError(domain: "ToDo", code: 0) }
//                try await repository.updateToDo(toDoList: todoToEdit, activity: activity, isDone: true)
            }
            return true
        }
        catch {
            errorMessage = error.localizedDescription
        }
        return false
    }
}
