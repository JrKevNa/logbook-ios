//
//  ViewProjectScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 09/12/25.
//
import SwiftUI

struct ViewProjectScreen: View {
    let project: Project

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(project.name).font(.title)
            Text("Requested By: \(project.requestedBy)")
            Text("Worked By: \(project.workedBy.username)")
            // ... rest of your fields
        }
        .padding()
        .navigationTitle("Project Details")
        .toolbar {
            NavigationLink("Edit") {
                AddProjectScreen(mode: .edit, project: project)
            }
        }
    }
}
