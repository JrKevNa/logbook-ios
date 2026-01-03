//
//  DetailProjectScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 08/12/25.
//

import SwiftUI

struct DetailProjectScreen: View {
    @StateObject private var vm: DetailProjectViewModel
    @State private var searchTerm = ""

    var filteredDetailProjects: [DetailProject] {
        if searchTerm.isEmpty {
            return vm.detailProjects
        } else {
            return vm.detailProjects.filter {
                $0.activity.localizedCaseInsensitiveContains(searchTerm)
            }
        }
    }
    
    init(project: Project) {
        _vm = StateObject(wrappedValue: DetailProjectViewModel(project: project))
    }

//    var body: some View {
//        ScrollView {
//            VStack(alignment: .leading, spacing: 12) {
//                Text(vm.project.name)
//                    .font(.title)
//                    .bold()
//
//                Text("Requested By: \(vm.project.requestedBy)")
//                Text("Worked By: \(vm.project.workedBy.username)")
//            }
//            .padding()
//        }
//        .navigationTitle("Project Detail")
//        .toolbar {
//            NavigationLink("Edit") {
//                AddProjectScreen(mode: .edit, project: vm.project)
//            }
//        }
//        .task { await vm.reload() }
//    }
    
    var body: some View {
        NavigationStack {
            VStack {

                // ⭐ PROJECT INFO HEADER
                VStack(alignment: .leading, spacing: 8) {
                    Text(vm.project.name)
                        .font(.title2)
                        .bold()

                    Text("Requested By: \(vm.project.requestedBy)")
                        .font(.subheadline)

                    Text("Worked By: \(vm.project.workedBy.username)")
                        .font(.subheadline)

                    Text("Start Date: \(vm.formattedDate(from: vm.project.startDate))")
                        .font(.caption)
                        .foregroundColor(.gray)

                    Text("End Date: \(vm.formattedDate(from: vm.project.endDate))")
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(UIColor.secondarySystemBackground))
                .cornerRadius(10)
                .padding(.horizontal)

                // ⭐ SEARCH BAR
                HStack {
                    TextField("Search detail project...", text: $searchTerm)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .textInputAutocapitalization(.none)

                    NavigationLink(
                        destination: AddDetailProjectScreen(
                            mode: .add,
                            projectId: vm.project.id
                        )
                    ) {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                            .padding(.leading, 4)
                    }
                }
                .padding(.horizontal)

                // ⭐ CONTENT
                if vm.isLoading && vm.detailProjects.isEmpty {
                    ProgressView().padding()
                } else if let error = vm.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(filteredDetailProjects, id: \.id) { detail in
                        NavigationLink(
                            destination: AddDetailProjectScreen(
                                mode: .edit,
                                detailProject: detail,
                                projectId: vm.project.id
                            )
                        ) {
                            VStack(alignment: .leading) {
                                Text(detail.activity)
                                    .font(.headline)

                                Text("Requested By: \(detail.requestedBy)")
                                    .font(.subheadline)

                                Text("Worked By: \(detail.workedBy.username)")
                                    .font(.subheadline)

                                Text(vm.formattedDate(from: detail.requestDate))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onAppear {
                            Task { await vm.loadNextIfNeeded(currentItem: detail) }
                        }
                    }
                }
            }
            .navigationTitle("Detail Project")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(
                        "Edit Project",
                        destination: AddProjectScreen(
                            mode: .edit,
                            project: vm.project
                        )
                    )
                }
            }
            .task { await vm.reloadAll() }
        }
    }
    
}
