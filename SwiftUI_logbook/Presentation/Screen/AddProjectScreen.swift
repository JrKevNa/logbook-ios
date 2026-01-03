//
//  AddProjectScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 08/12/25.
//

import SwiftUI

struct AddProjectScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm = AddProjectViewModel()
    
    // ✅ Custom initializer
    init(mode: ModalMode = .add, project: Project? = nil) {
        _vm = StateObject(wrappedValue: AddProjectViewModel(mode: mode, project: project))
    }
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 8) {
                Text("Name")
                    .font(.headline)

                TextEditor(text: $vm.name)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
            }
            .padding(.vertical, 12)
            
            Picker("Worked By", selection: $vm.workedBy) {
                Text("None").tag(Optional<User>(nil))   // <-- Add this

                ForEach(vm.users, id: \.id) { user in
                    Text(user.username).tag(Optional(user))
                }
            }
            HStack {
                Text("Requested By")
                Spacer()
                TextField("", text: $vm.requestedBy)
                    .multilineTextAlignment(.trailing)   // <-- right-aligned text
            }
            
            DatePicker("Start Date", selection: $vm.startDate, displayedComponents: .date)
            DatePicker("End Date", selection: $vm.endDate, displayedComponents: .date)
            
            // Show error if present
            if let error = vm.errorMessage {
                Text(error)
                    .foregroundColor(.red)
            }
        }
        .navigationTitle(vm.projectToEdit == nil ? "Add Project" : "Edit Project")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(vm.projectToEdit == nil ? "Add" : "Save") {
                    Task {
                        let success = await vm.save()
                        if success {
                            dismiss()
                        }
                    }
                }
            }
        }
    }
}
