//
//  UserScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 16/12/25.
//

import SwiftUI

struct UserScreen: View {
    @EnvironmentObject var appState: AppState
    @StateObject private var vm = UserViewModel()
    @State private var searchTerm = ""
    
    var filteredUsers: [User] {
        if searchTerm.isEmpty {
            return vm.users
        } else {
            return vm.users.filter { $0.username.localizedCaseInsensitiveContains(searchTerm) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                if appState.currentUser?.isAdmin == true {
                    // Search Bar
                    TextField("Search user name...", text: $searchTerm)
                        .padding(8)
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                        .padding(.horizontal)
                        .textInputAutocapitalization(.none)
                    
                    if vm.isLoading && vm.users.isEmpty {
                        ProgressView()
                            .padding()
                    } else if let error = vm.errorMessage {
                        Text("Error: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        List(filteredUsers, id: \.id) { user in
                            // NavigationLink(destination: AddProjectScreen(mode: .edit, project: project)) {
                            NavigationLink(
                                destination: AddUserScreen(
                                    mode: .edit,
                                    user: user)
                            ) {
                                VStack(alignment: .leading) {
                                    Text(user.username).font(.headline)
                                    Text("NIK: \(user.nik ?? "Unknown") ").font(.subheadline)
                                    Text("Email: \(user.email ?? "Unknown") ").font(.subheadline)
                                    Text("Role: \(user.userRoles?.first?.role.name ?? "Unknown") ").font(.subheadline)
                                }
                            }
                            .onAppear {
                                Task {
                                    await vm.loadNextIfNeeded(currentItem: user)
                                }
                            }
                        }
                    }
                } else {
                    Text("You do not have permission to access this page.")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle("Users")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddUserScreen(mode: .add))
                }
            }
            .task {
                await vm.reloadAll()
            }
        }
    }
}
