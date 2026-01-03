//
//  ToDoListScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 03/12/25.
//

import SwiftUI

struct ToDoListScreen: View {
    @StateObject private var vm = ToDoListViewModel()
    @State private var searchTerm = ""
    
    var filteredTodos: [ToDoList] {
        if searchTerm.isEmpty {
            return vm.toDoList
        } else {
            return vm.toDoList.filter { $0.activity.localizedCaseInsensitiveContains(searchTerm) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search
                TextField("Search activity...", text: $searchTerm)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.none)
                
                if vm.isLoading && vm.toDoList.isEmpty {
                    ProgressView()
                        .padding()
                } else if let error = vm.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(filteredTodos, id: \.id) { todo in
                        NavigationLink(destination: AddToDoScreen(mode: .edit, todo: todo)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(todo.activity)
                                        .font(.headline)

                                    Text(vm.formattedDate(todo.createDate))
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                }

                                Spacer()

                                if todo.isDone {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                        .imageScale(.large)
                                }
                            }
                        }
                        .onAppear {
                            Task { await vm.loadNextIfNeeded(currentItem: todo) }
                        }
                    }
                }
            }
            .navigationTitle("To Do List")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddToDoScreen(mode: .add))
                }
            }
            .task {
                await vm.reloadAll()
            }
        }
    }
}
