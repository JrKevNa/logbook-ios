//
//  ViewModels.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

@MainActor
class LogbookViewModel: ObservableObject {
    @Published var logbooks: [Logbook] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: LogbookRepository
    private let limit = 10

    // Track pagination
    private var currentPage = 1
    private var totalPages = 1
    
    init(repository: LogbookRepository = LogbookRepository()) {
        self.repository = repository
    }

    func formattedDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        }
        return dateString
    }
    
    func loadPage(_ page: Int) async {
        guard !isLoading else { return }
        guard page <= totalPages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {

            let response = try await self.repository.fetchLogbooks(page: page, limit: self.limit, forceRefresh: true)
        
            // let response = try await repository.fetchLogbooks(page: page, limit: limit, forceRefresh: true)
            
            if page == 1 {
                logbooks = response.logbooks
            } else {
                logbooks.append(contentsOf: response.logbooks)
            }
            
            currentPage = page
            totalPages = response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadNextIfNeeded(currentItem item: Logbook) async {
        
//        print("last logbook")
//        print(logbooks.last)
        guard let last = logbooks.last else { return }
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
