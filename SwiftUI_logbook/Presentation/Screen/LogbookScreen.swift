//
//  LogbookScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 02/12/25.
//

import SwiftUI

struct LogbookScreen: View {
    @StateObject private var vm = LogbookViewModel()
    @State private var searchTerm = ""
    
    var filteredLogbooks: [Logbook] {
        if searchTerm.isEmpty {
            return vm.logbooks
        } else {
            return vm.logbooks.filter { $0.activity.localizedCaseInsensitiveContains(searchTerm) }
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                TextField("Search activity...", text: $searchTerm)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
                    .padding(.horizontal)
                    .textInputAutocapitalization(.none)
                
                if vm.isLoading && vm.logbooks.isEmpty {
                    ProgressView()
                        .padding()
                } else if let error = vm.errorMessage {
                    Text("Error: \(error)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    List(filteredLogbooks, id: \.id) { log in
                        NavigationLink(destination: AddLogbookScreen(mode: .edit, logbook: log)) {
                            VStack(alignment: .leading) {
                                Text(log.activity).font(.headline)
                                Text("Duration: \(log.durationNumber) \(log.durationUnit)").font(.subheadline)
                                Text(vm.formattedDate(from: log.logDate))
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                        }
                        .onAppear {
                            Task {
                                await vm.loadNextIfNeeded(currentItem: log)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Logbooks")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink("Add", destination: AddLogbookScreen(mode: .add))
                }
            }
            .task {
                await vm.reloadAll()
            }
        }
    }
}
