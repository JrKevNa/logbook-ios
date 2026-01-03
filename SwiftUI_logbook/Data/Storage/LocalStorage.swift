//
//  LocalStorage.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//
import Foundation

protocol LocalStorageProtocol {
    func saveLogbooks(_ logbooks: [Logbook])
    func getLogbooks() -> [Logbook]
    func clearLogbooks()
    
    func saveToDoList(_ toDoList: [ToDoList])
    func getToDoList() -> [ToDoList]
    func clearToDoList()
    
    func saveProjects(_ projects: [Project])
    func getProjects() -> [Project]
    func clearProjects()
    
    func saveDetailProjects(_ detailProjects: [DetailProject])
    func getDetailProjects() -> [DetailProject]
    func clearDetailProjects()
    
    func saveUsers(_ users: [User])
    func getUsers() -> [User]
    func clearUsers()
}

class LocalStorage: LocalStorageProtocol {
    static let shared = LocalStorage()
    
    private let logbooksKey = "cachedLogbooks"
    private let projectsKey = "cachedProjects"
    private let detailProjectsKey = "cachedDetailProjects"
    private let toDoListKey = "cachedToDoList"
    private let usersKey = "cachedUsers"
    
    // MARK: - Log Book
    func saveLogbooks(_ logbooks: [Logbook]) {
        if let data = try? JSONEncoder().encode(logbooks) {
            UserDefaults.standard.set(data, forKey: logbooksKey)
        }
    }
    
    func getLogbooks() -> [Logbook] {
        guard let data = UserDefaults.standard.data(forKey: logbooksKey),
              let logbooks = try? JSONDecoder().decode([Logbook].self, from: data) else {
            return []
        }
        return logbooks
    }
    
    func clearLogbooks() {
        UserDefaults.standard.removeObject(forKey: logbooksKey)
    }
    
    // MARK: - To Do List
    func saveToDoList(_ toDoList: [ToDoList]) {
        if let data = try? JSONEncoder().encode(toDoList) {
            UserDefaults.standard.set(data, forKey: logbooksKey)
        }
    }
    
    func getToDoList() -> [ToDoList] {
        guard let data = UserDefaults.standard.data(forKey: toDoListKey),
              let toDoList = try? JSONDecoder().decode([ToDoList].self, from: data) else {
            return []
        }
        return toDoList
    }
    
    func clearToDoList() {
        UserDefaults.standard.removeObject(forKey: toDoListKey)
    }
    
    // MARK: - Project
    func saveProjects(_ projects: [Project]) {
        if let data = try? JSONEncoder().encode(projects) {
            UserDefaults.standard.set(data, forKey: projectsKey)
        }
    }
    
    func getProjects() -> [Project] {
        guard let data = UserDefaults.standard.data(forKey: projectsKey),
              let projects = try? JSONDecoder().decode([Project].self, from: data) else {
            return []
        }
        return projects
    }
    
    func clearProjects() {
        UserDefaults.standard.removeObject(forKey: projectsKey)
    }
    
    // MARK: - Detail Project
    func saveDetailProjects(_ detailProjects: [DetailProject]) {
        if let data = try? JSONEncoder().encode(detailProjects) {
            UserDefaults.standard.set(data, forKey: detailProjectsKey)
        }
    }
    
    func getDetailProjects() -> [DetailProject] {
        guard let data = UserDefaults.standard.data(forKey: detailProjectsKey),
              let detailProjects = try? JSONDecoder().decode([DetailProject].self, from: data) else {
            return []
        }
        return detailProjects
    }
    
    func clearDetailProjects() {
        UserDefaults.standard.removeObject(forKey: detailProjectsKey)
    }
    
    // MARK: - User
    func saveUsers(_ users: [User]) {
        if let data = try? JSONEncoder().encode(users) {
            UserDefaults.standard.set(data, forKey: usersKey)
        }
    }
    
    func getUsers() -> [User] {
        guard let data = UserDefaults.standard.data(forKey: usersKey),
              let users = try? JSONDecoder().decode([User].self, from: data) else {
            return []
        }
        return users
    }
    
    func clearUsers() {
        UserDefaults.standard.removeObject(forKey: usersKey)
    }
}
