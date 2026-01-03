//
//  AddDetailProjectScreen.swift
//  SwiftUI_logbook
//
//  Created by Kevin on 09/12/25.
//

import SwiftUI

struct AddDetailProjectScreen: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var vm: AddDetailProjectViewModel
    
    init(mode: ModalMode = .add, detailProject: DetailProject? = nil, projectId: String = "") {
        _vm = StateObject(wrappedValue: AddDetailProjectViewModel(mode: mode, detailProject: detailProject, projectId: projectId))
    }
    
    var body: some View {
        Form {
            VStack(alignment: .leading, spacing: 8) {
                Text("activity")
                    .font(.headline)

                TextEditor(text: $vm.activity)
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
            
            DatePicker("Request Date", selection: $vm.requestDate, displayedComponents: .date)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Note")
                    .font(.headline)

                TextEditor(text: $vm.note)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color(UIColor.secondarySystemBackground))
                    .cornerRadius(8)
            }
            .padding(.vertical, 12)
        }
        .navigationTitle(vm.detailProjectToEdit == nil ? "Add Detail Project" : "Edit Detail Project")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(vm.detailProjectToEdit == nil ? "Add" : "Save") {
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
