//
//  ProjectScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 08/12/25.
//

import SwiftUI

struct ProjectScreen: View {
    @StateObject private var vm = ProjectViewModel()
    @State private var searchTerm = ""

    var filteredProjects: [Project] {
        if searchTerm.isEmpty {
            return vm.projects
        } else {
            return vm.projects.filter { $0.name.localizedCaseInsensitiveContains(searchTerm) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                TextField("Search project name...", text: $searchTerm)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.none)
                
                if vm.isLoading && vm.projects.isEmpty {
                    ProgressView()
                        .padding()
                } else if let error = vm.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(filteredProjects, id: \.id) { project in
                        // NavigationLink(destination: AddProjectScreen(mode: .edit, project: project)) {
                        NavigationLink(
                            destination: DetailProjectScreen(
                                project: project)
                        ) {
                            VStack(alignment: .leading) {
                                Text(project.name).font(.headline)
                                Text("Requested By: \(project.requestedBy) ").font(.subheadline)
                                Text("Worked By: \(project.workedBy.username) ").font(.subheadline)
                                Text(vm.formattedDate(from: project.startDate))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(vm.formattedDate(from: project.endDate))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onAppear {
                            Task {
                                await vm.loadNextIfNeeded(currentItem: project)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Projects")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddProjectScreen(mode: .add))
                }
            }
            .task {
                await vm.reloadAll()
            }
        }
    }
}
