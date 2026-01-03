//
//  DetailProjectViewModel.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 09/12/25.
//
import SwiftUI

@MainActor
class DetailProjectViewModel: ObservableObject {
    @Published var project: Project
    @Published var detailProjects: [DetailProject] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let repository = ProjectRepository()
    private let detailProjectRepository = DetailProjectRepository()
    
    private let limit = 10

    // Track pagination
    private var currentPage = 1
    private var totalPages = 1
    
    init(project: Project) {
        self.project = project
    }

    func formattedDate(from dateString: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        if let date = formatter.date(from: dateString) {
            return DateFormatter.localizedString(from: date, dateStyle: .medium, timeStyle: .none)
        }
        return dateString
    }
    
    func reload() async {
        if let refreshed = try? await repository.fetchProjectById(id: project.id) {
            self.project = refreshed
        }
    }
    
    func loadPage(_ page: Int) async {
        guard !isLoading else { return }
        guard page <= totalPages else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {

            let response = try await self.detailProjectRepository.fetchDetailProjects(id: project.id, page: page, limit: self.limit, forceRefresh: true)
        
            // let response = try await repository.fetchLogbooks(page: page, limit: limit, forceRefresh: true)
            
            if page == 1 {
                detailProjects = response.detailProjects
            } else {
                detailProjects.append(contentsOf: response.detailProjects)
            }
            
            currentPage = page
            totalPages = response.totalPages
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func loadNextIfNeeded(currentItem item: DetailProject) async {
        
//        print("last logbook")
//        print(logbooks.last)
        guard let last = detailProjects.last else { return }
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
        await reload()
    }
}
