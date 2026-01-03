//
//  ToDoRepository.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 05/12/25.
//

import SwiftUI

class ToDoListRepository {
    private let api: APIService
    private let storage: LocalStorageProtocol
    
    init(api: APIService = .shared, storage: LocalStorageProtocol = LocalStorage.shared) {
        self.api = api
        self.storage = storage
    }
    
    func fetchToDoList(page: Int = 1, limit: Int = 10, forceRefresh: Bool = false) async throws -> (toDoList: [ToDoList], totalPages: Int) {
        if !forceRefresh, page == 1 {
            let cached = storage.getToDoList()
            if !cached.isEmpty {
                // Optionally assume totalPages = 1 for cached data
                return (cached, 1)
            }
        }

        let paginatedResponse = try await api.fetchToDoList(page: page, limit: limit)

        let toDoList = paginatedResponse.toDoList
        let totalPages = paginatedResponse.totalPages

        if page == 1 {
            storage.saveToDoList(toDoList) // only cache first page
        }

        print("API returned page \(page) with \(paginatedResponse.toDoList.count) items, totalPages: \(paginatedResponse.totalPages)")
        
        return (toDoList, totalPages)
    }

    
    // MARK: - Add To Do
    func addToDo(activity: String) async throws {
        let request = CreateToDoRequest(
            activity: activity,
        )

        try await api.addToDo(request)
        
        // Refresh cached logbooks
        let updatedToDoList = try await api.fetchToDoList().toDoList
        storage.saveToDoList(updatedToDoList)
    }

    // MARK: - Update To Do
    func updateToDo(toDoList: ToDoList, activity: String) async throws {
        let request = UpdateToDoRequest(
            activity: activity,
        )

        try await api.updateToDo(id: toDoList.id, data: request)
        
        // Refresh cached logbooks
        let updatedToDoList = try await api.fetchToDoList().toDoList
        storage.saveToDoList(updatedToDoList)
    }
    
    // MARK: - Finish To Do
    func finishToDo(_ toDoList: ToDoList) async throws {
        let request = FinishToDoRequest(
            isDone: true,
        )

        try await api.finishToDo(id: toDoList.id, data: request)
        
        // Refresh cached logbooks
        let updatedToDoList = try await api.fetchToDoList().toDoList
        storage.saveToDoList(updatedToDoList)
    }
    
    // MARK: - Delete To Do
    func deleteToDo(_ toDoList: ToDoList) async throws {
        try await api.deleteToDo(id: toDoList.id)
        
        // Refresh cached logbooks
        let updatedToDoList = try await api.fetchToDoList().toDoList
        storage.saveToDoList(updatedToDoList)
    }
    
    func getCachedLogbooks() -> [Logbook] {
        storage.getLogbooks()
    }
    
    func getToDoList() -> [ToDoList] {
        storage.getToDoList()
    }
}
