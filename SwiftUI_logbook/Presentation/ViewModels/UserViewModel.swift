//
//  UserViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 16/12/25.
//

import SwiftUI

@MainActor
class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: UserRepository
    private let limit = 10

    // Track pagination
    private var currentPage = 1
    private var totalPages = 1
    
    init(repository: UserRepository = UserRepository()) {
        self.repository = repository
    }
    
    func loadPage(_ page: Int) async {
        guard !isLoading else { return }
        guard page <= totalPages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {

            let response = try await self.repository.fetchUsers(page: page, limit: self.limit, forceRefresh: true)
        
            // let response = try await repository.fetchLogbooks(page: page, limit: limit, forceRefresh: true)
            
            if page == 1 {
                users = response.users
            } else {
                users.append(contentsOf: response.users)
            }
            
            currentPage = page
            totalPages = response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadNextIfNeeded(currentItem item: User) async {
        
//        print("last logbook")
//        print(logbooks.last)
        guard let last = users.last else { return }
//        print("item id")
//        print(item.id)
        guard item.id == last.id else { return }
//        print("item id compared")
//        print(item.id)
//        print("last logbook compared")
//        print(last.id)
        guard currentPage < totalPages else { return }
//        print("currentPage")
//        print(currentPage)
//        print("totalPages")
//        print(totalPages)
        
        await loadPage(currentPage + 1)
    }
    
    func reloadAll() async {
        currentPage = 1
        await loadPage(1)
    }
}
