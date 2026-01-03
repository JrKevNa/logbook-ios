//
//  ToDoListViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 05/12/25.
//

import SwiftUI

@MainActor
class ToDoListViewModel: ObservableObject {
    @Published var toDoList: [ToDoList] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repository: ToDoListRepository
    private let limit = 10

    // Pagination
    private var currentPage = 1
    private var totalPages = 1

    init(repository: ToDoListRepository = ToDoListRepository()) {
        self.repository = repository
    }

    func formattedDate(_ date: Date) -> String {
        return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
    }

    func loadPage(_ page: Int) async {
        guard !isLoading else { return }
        guard page <= totalPages else { return }

        isLoading = true
        errorMessage = nil

        do {
            let response = try await repository.fetchToDoList(page: page, limit: limit, forceRefresh: true)

            if page == 1 {
                toDoList = response.toDoList
            } else {
                toDoList.append(contentsOf: response.toDoList)
            }

            currentPage = page
            totalPages = response.totalPages

        } catch {
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }

    func loadNextIfNeeded(currentItem item: ToDoList) async {
        guard let last = toDoList.last else { return }
        guard item.id == last.id else { return }
        guard currentPage < totalPages else { return }

        await loadPage(currentPage + 1)
    }

    func reloadAll() async {
        currentPage = 1
        await loadPage(1)
    }
}
